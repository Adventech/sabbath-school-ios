#!/usr/bin/env python3
"""Regression checks for durable local user-input persistence.

This script is intentionally runnable without Xcode so the storage contract can
be checked in CI and on non-macOS audit hosts.  It verifies the safety-critical
ordering in SyncManager and that callers do not upload an input after its local
write has failed.
"""

from pathlib import Path
from copy import deepcopy
import re
import sys
from typing import Dict, List, Optional, Set


ROOT = Path(__file__).resolve().parents[1]
SYNC_MANAGER = ROOT / "Sabbath School/Common/Configuration/SyncManager.swift"
DOCUMENT_VIEW_MODEL = ROOT / "Sabbath School/View/Document/DocumentViewModel.swift"


def function_body(source: str, signature: str) -> str:
    """Return a Swift function body using balanced braces."""
    start = source.find(signature)
    if start < 0:
        return ""
    opening = source.find("{", start)
    if opening < 0:
        return ""

    depth = 0
    for index in range(opening, len(source)):
        if source[index] == "{":
            depth += 1
        elif source[index] == "}":
            depth -= 1
            if depth == 0:
                return source[opening + 1 : index]
    return ""


def ordered(body: str, *needles: str) -> bool:
    position = -1
    for needle in needles:
        position = body.find(needle, position + 1)
        if position < 0:
            return False
    return True


class InjectedDiskFault(Exception):
    pass


class FaultStorage:
    """Minimal Cache-compatible model: set mutates memory before disk."""

    def __init__(self, canonical: List[str]):
        self.disk = {"document": deepcopy(canonical)}
        self.memory: Dict[str, List[str]] = {}
        self.fail_write: Set[str] = set()
        self.drop_write: Set[str] = set()
        self.fail_remove: Set[str] = set()

    def set(self, key: str, value: List[str]) -> None:
        self.memory[key] = deepcopy(value)
        if key in self.fail_write:
            raise InjectedDiskFault(f"write:{key}")
        if key not in self.drop_write:
            self.disk[key] = deepcopy(value)

    def evict(self, key: str) -> None:
        self.memory.pop(key, None)

    def read(self, key: str) -> Optional[List[str]]:
        if key in self.memory:
            return deepcopy(self.memory[key])
        if key not in self.disk:
            return None
        self.memory[key] = deepcopy(self.disk[key])
        return deepcopy(self.disk[key])

    def remove(self, key: str) -> None:
        self.memory.pop(key, None)
        if key in self.fail_remove:
            raise InjectedDiskFault(f"remove:{key}")
        self.disk.pop(key, None)


def persist_and_validate(storage: FaultStorage, key: str, value: List[str]) -> None:
    try:
        storage.set(key, value)
    except InjectedDiskFault:
        storage.evict(key)
        raise
    storage.evict(key)
    if storage.read(key) != value:
        raise InjectedDiskFault(f"validation:{key}")


def journaled_save(storage: FaultStorage, value: str) -> None:
    recovery_key = "recovery:document"
    pending = storage.read(recovery_key)
    if pending is not None:
        persist_and_validate(storage, "document", pending)
        storage.remove(recovery_key)
        current = pending
    else:
        current = storage.read("document") or []

    updated = current + [value]
    persist_and_validate(storage, recovery_key, updated)
    persist_and_validate(storage, "document", updated)
    storage.remove(recovery_key)


def preferred_read(storage: FaultStorage) -> List[str]:
    pending = storage.read("recovery:document")
    if pending is not None:
        try:
            persist_and_validate(storage, "document", pending)
            storage.remove("recovery:document")
        except InjectedDiskFault:
            pass
        return pending
    return storage.read("document") or []


def fault_model_passes() -> bool:
    # A recovery write failure leaves the canonical last-known-good value intact.
    recovery_failure = FaultStorage(["old"])
    recovery_failure.fail_write.add("recovery:document")
    try:
        journaled_save(recovery_failure, "new")
        return False
    except InjectedDiskFault:
        if preferred_read(recovery_failure) != ["old"]:
            return False

    # A canonical write failure leaves a validated recovery value, which the
    # next transaction promotes before it accepts another edit.
    canonical_failure = FaultStorage(["old"])
    canonical_failure.fail_write.add("document")
    try:
        journaled_save(canonical_failure, "new")
        return False
    except InjectedDiskFault:
        if preferred_read(canonical_failure) != ["old", "new"]:
            return False
    canonical_failure.fail_write.clear()
    if preferred_read(canonical_failure) != ["old", "new"]:
        return False
    if "recovery:document" in canonical_failure.disk:
        return False
    journaled_save(canonical_failure, "newer")
    if preferred_read(canonical_failure) != ["old", "new", "newer"]:
        return False

    # Cache can report success after a dropped createFile write. Eviction makes
    # the validation read hit disk and detect the stale canonical bytes.
    silent_drop = FaultStorage(["old"])
    silent_drop.drop_write.add("document")
    try:
        journaled_save(silent_drop, "new")
        return False
    except InjectedDiskFault:
        if preferred_read(silent_drop) != ["old", "new"]:
            return False

    # Failed journal cleanup is recoverable: both durable copies contain the
    # new value and the recovery copy remains preferred.
    cleanup_failure = FaultStorage(["old"])
    cleanup_failure.fail_remove.add("recovery:document")
    try:
        journaled_save(cleanup_failure, "new")
        return False
    except InjectedDiskFault:
        return preferred_read(cleanup_failure) == ["old", "new"]


def main() -> int:
    sync_source = SYNC_MANAGER.read_text(encoding="utf-8")
    view_model_source = DOCUMENT_VIEW_MODEL.read_text(encoding="utf-8")

    read_body = function_body(sync_source, "func readStoredInput(")
    get_body = function_body(sync_source, "func getLocalInput(")
    get_unsynced_body = function_body(sync_source, "func getAllUnsyncedLocalInputs(")
    mark_synced_body = function_body(sync_source, "func markAsSynced(")
    save_body = function_body(sync_source, "func saveLocalInput(")
    persist_body = function_body(sync_source, "func persistAndValidate(")
    promotion_body = function_body(sync_source, "func promotePendingRecovery(")
    user_save_body = function_body(view_model_source, "func saveBlockUserInput(")
    retrieval_body = function_body(view_model_source, "func retrieveDocumentUserInput(")

    checks = [
        (
            "saveLocalInput propagates persistence errors and cannot report optional success",
            bool(
                re.search(
                    r"func\s+saveLocalInput\s*\([^)]*\)\s*throws\s*->\s*LocalUserInput\b",
                    sync_source,
                    re.DOTALL,
                )
            ),
        ),
        (
            "saveLocalInput serializes read-modify-write transactions",
            "persistenceQueue.sync" in save_body,
        ),
        (
            "sync acknowledgements cannot interleave with a local save transaction",
            "persistenceQueue.sync" in mark_synced_body,
        ),
        (
            "reads prefer a pending recovery record before canonical data",
            ordered(
                get_body,
                "recoveryKey(for: documentIndex)",
                "promotePendingRecovery",
                "readStoredInput(forKey: recoveryKey",
                "readStoredInput(forKey: documentIndex",
            ),
        ),
        (
            "corrupt data is propagated instead of being mistaken for an empty document",
            "catch StorageError.notFound" in read_body
            and "fileReadNoSuchFile" in read_body
            and "catch {" not in read_body,
        ),
        (
            "unsynced retries include recoverable journal data",
            "getLocalInput(documentIndex: documentId)" in get_unsynced_body,
        ),
        (
            "saveLocalInput promotes an existing recovery record before staging a replacement",
            ordered(
                save_body,
                "promotePendingRecovery",
                "persistAndValidate(updatedInputs, forKey: recoveryKey, using: storage",
            ),
        ),
        (
            "saveLocalInput stages and validates recovery before canonical data, then removes recovery",
            ordered(
                save_body,
                "persistAndValidate(updatedInputs, forKey: recoveryKey, using: storage",
                "persistAndValidate(updatedInputs, forKey: documentIndex, using: storage",
                "removeObject(forKey: recoveryKey)",
            ),
        ),
        (
            "writes are throwing (never try?) and are followed by memory eviction plus disk read-back",
            "try?" not in persist_body
            and ordered(
                persist_body,
                "try storage.setObject",
                "try storage.removeInMemoryObject",
                "try readStoredInput",
                "encodedInputs",
            ),
        ),
        (
            "recovery promotion validates canonical storage before deleting the journal",
            ordered(
                promotion_body,
                "try readStoredInput",
                "try persistAndValidate(pendingInputs, forKey: documentIndex, using: storage",
                "try storage.removeObject(forKey: recoveryKey)",
            ),
        ),
        (
            "the user-edit caller requires a successful local save before encoding or POSTing",
            ordered(
                user_save_body,
                "try SyncManager.shared.saveLocalInput",
                "JSONSerialization.jsonObject",
                "API.auth.request",
            ),
        ),
        (
            "the remote-merge caller handles the throwing persistence API",
            "try SyncManager.shared.saveLocalInput" in retrieval_body,
        ),
        (
            "the old swallowed-write pattern is absent from saveLocalInput",
            not re.search(r"try\?\s+.*setObject", save_body),
        ),
        (
            "fault model preserves old or recovery data across write, validation, and cleanup faults",
            fault_model_passes(),
        ),
    ]

    failed = [description for description, passed in checks if not passed]
    for description, passed in checks:
        print(f"{'PASS' if passed else 'FAIL'}: {description}")

    if failed:
        print(
            "\nDurability regression detected: the current implementation can acknowledge "
            "a local input without proving it reached disk.",
            file=sys.stderr,
        )
        return 1

    print("\nAll local-input durability regression checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
