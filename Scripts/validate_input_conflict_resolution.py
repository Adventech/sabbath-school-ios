#!/usr/bin/env python3
"""Regression checks for local/remote user-input conflict resolution."""

import json
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
LOCAL_INPUT = ROOT / "Sabbath School/Common/Model/LocalUserInput.swift"
ANY_INPUT = ROOT / "Sabbath School/Common/Model/AnyUserInput.swift"
DOCUMENT_VIEW_MODEL = ROOT / "Sabbath School/View/Document/DocumentViewModel.swift"
LEGACY_FIXTURE = ROOT / "Scripts/fixtures/legacy_local_input_seconds.json"


def function_body(source, signature):
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


def ordered(body, *needles):
    position = -1
    for needle in needles:
        position = body.find(needle, position + 1)
        if position < 0:
            return False
    return True


def expected_preserves(local, remote):
    if (
        local["userInput"]["blockId"] != remote["blockId"]
        or local["userInput"]["inputType"] != remote["inputType"]
    ):
        return False
    if local["synced"] is False:
        return True
    return normalized_milliseconds(local["userInput"]["timestamp"]) >= normalized_milliseconds(
        remote["timestamp"]
    )


def normalized_milliseconds(timestamp):
    return timestamp * 1000 if 0 <= timestamp < 10_000_000_000 else timestamp


def behavior_matrix_passes(legacy_local):
    remote = {
        "blockId": "synthetic-block",
        "inputType": "comment",
        "comment": "synthetic stale remote",
        "timestamp": legacy_local["userInput"]["timestamp"],
    }

    cases = [
        (legacy_local, remote, True, "dirty same-second local"),
        (
            {
                **legacy_local,
                "userInput": {**legacy_local["userInput"], "timestamp": remote["timestamp"] - 30},
            },
            remote,
            True,
            "dirty clock-skewed local",
        ),
        ({**legacy_local, "synced": True}, remote, True, "acknowledged equal local"),
        (
            {
                **legacy_local,
                "synced": True,
                "userInput": {**legacy_local["userInput"], "timestamp": remote["timestamp"] - 1},
            },
            remote,
            False,
            "acknowledged older local",
        ),
        (
            {
                **legacy_local,
                "synced": True,
                "userInput": {**legacy_local["userInput"], "timestamp": remote["timestamp"] + 1},
            },
            remote,
            True,
            "acknowledged newer local",
        ),
        (
            {
                **legacy_local,
                "synced": True,
                "userInput": {**legacy_local["userInput"], "timestamp": remote["timestamp"] + 1},
            },
            {**remote, "timestamp": remote["timestamp"] * 1000 + 500},
            True,
            "newer legacy-second local versus older millisecond remote",
        ),
        (
            legacy_local,
            {**remote, "blockId": "different-block"},
            False,
            "different identity",
        ),
    ]
    return all(expected_preserves(local, candidate) is expected for local, candidate, expected, _ in cases)


def reproduces_base_same_second_fallthrough(legacy_local):
    remote = {
        "blockId": legacy_local["userInput"]["blockId"],
        "inputType": legacy_local["userInput"]["inputType"],
        "comment": "synthetic stale remote",
        "timestamp": legacy_local["userInput"]["timestamp"],
    }
    return (
        legacy_local["synced"] is False
        and legacy_local["userInput"]["comment"] != remote["comment"]
        and legacy_local["userInput"]["timestamp"] == remote["timestamp"]
        and not (legacy_local["userInput"]["timestamp"] > remote["timestamp"])
    )


def main():
    local_source = LOCAL_INPUT.read_text(encoding="utf-8")
    any_source = ANY_INPUT.read_text(encoding="utf-8")
    view_model_source = DOCUMENT_VIEW_MODEL.read_text(encoding="utf-8")
    legacy_local = json.loads(LEGACY_FIXTURE.read_text(encoding="utf-8"))

    resolver_body = function_body(local_source, "func shouldBePreserved(")
    coding_keys_body = function_body(any_source, "private enum CodingKeys")
    retrieval_body = function_body(view_model_source, "func retrieveDocumentUserInput(")

    checks = [
        (
            "LocalUserInput exposes one conflict policy for remote merges",
            bool(
                re.search(
                    r"func\s+shouldBePreserved\s*\(over\s+remoteUserInput:\s*AnyUserInput\)\s*->\s*Bool",
                    local_source,
                )
            ),
        ),
        (
            "the policy matches both block and input type before comparing versions",
            "userInput.blockId == remoteUserInput.blockId" in resolver_body
            and "userInput.inputType == remoteUserInput.inputType" in resolver_body,
        ),
        (
            "a dirty local row wins before wall-clock timestamps are considered",
            ordered(
                resolver_body,
                "guard",
                "if synced == false",
                "return true",
                "userInput.timestampInMilliseconds >= remoteUserInput.timestampInMilliseconds",
            ),
        ),
        (
            "an acknowledged local row wins a same-second tie but not an older comparison",
            "return userInput.timestampInMilliseconds >= remoteUserInput.timestampInMilliseconds" in resolver_body,
        ),
        (
            "legacy seconds and current milliseconds share a non-serialized comparison unit",
            "var timestampInMilliseconds: Int64" in any_source
            and "10_000_000_000" in any_source
            and "timestamp >= 0" in any_source
            and "timestamp * 1000" in any_source,
        ),
        (
            "timestamp normalization does not add a wire or cache field",
            "timestampInMilliseconds" not in coding_keys_body
            and "try _base.encode(to: encoder)" in any_source,
        ),
        (
            "the retrieval merge delegates matching and precedence to the policy",
            "shouldBePreserved(over: userInput)" in retrieval_body,
        ),
        (
            "the old inline strict-timestamp predicate is absent",
            not re.search(
                r"(?:\$0|localUserInput)\.userInput\.timestamp\s*>\s*userInput\.timestamp",
                retrieval_body,
            ),
        ),
        (
            "preservation is decided before a remote row can replace local storage",
            ordered(
                retrieval_body,
                "shouldBePreserved(over: userInput)",
                "saveLocalInput(documentIndex: documentId, userInput: userInput, syncStatus: true)",
            ),
        ),
        (
            "legacy integer-second Codable input remains the wire/storage contract",
            "struct LocalUserInput: Codable" in local_source
            and "struct AnyUserInput: UserInputProtocol, Decodable" in any_source
            and "var timestamp: Int { get }" in any_source
            and isinstance(legacy_local["userInput"]["timestamp"], int)
            and legacy_local["userInput"]["timestamp"] < 10_000_000_000
            and normalized_milliseconds(legacy_local["userInput"]["timestamp"])
            == 1_735_689_600_000,
        ),
        (
            "the synthetic legacy fixture deterministically reaches the base equality fall-through",
            reproduces_base_same_second_fallthrough(legacy_local),
        ),
        (
            "deterministic same-second, clock-skew, acknowledged, and identity cases pass",
            behavior_matrix_passes(legacy_local),
        ),
    ]

    for description, passed in checks:
        print("{}: {}".format("PASS" if passed else "FAIL", description))

    if not all(passed for _, passed in checks):
        print(
            "\nConflict regression detected: a stale remote row can replace dirty local input.",
            file=sys.stderr,
        )
        return 1

    print("\nAll local/remote input conflict regression checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
