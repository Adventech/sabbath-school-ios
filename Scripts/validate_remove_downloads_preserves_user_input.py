#!/usr/bin/env python3
"""Guard the remove-downloads action from shared user-input storage APIs."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
SETTINGS_FILE = REPOSITORY_ROOT / "Sabbath School" / "View" / "Settings" / "SettingsView.swift"
CONFIGURATION_FILE = (
    REPOSITORY_ROOT
    / "Sabbath School"
    / "Common"
    / "Configuration"
    / "Configuration.swift"
)
DOWNLOAD_MANAGER_FILE = (
    REPOSITORY_ROOT
    / "Sabbath School"
    / "Common"
    / "Configuration"
    / "DownloadManager.swift"
)
SYNC_MANAGER_FILE = (
    REPOSITORY_ROOT
    / "Sabbath School"
    / "Common"
    / "Configuration"
    / "SyncManager.swift"
)

SAFE_CONFIGURATION_METHOD = "clearDownloadedContent"
SAFE_DOWNLOAD_MANAGER_METHOD = "clearInMemoryDownloads"


def function_body(source: str, name: str) -> str | None:
    declaration = re.search(
        rf"\b(?:public\s+)?static\s+func\s+{re.escape(name)}\s*\([^)]*\)\s*\{{",
        source,
    )
    if declaration is None:
        return None

    opening_brace = declaration.end() - 1
    depth = 0
    for index in range(opening_brace, len(source)):
        if source[index] == "{":
            depth += 1
        elif source[index] == "}":
            depth -= 1
            if depth == 0:
                return source[opening_brace + 1 : index]
    return None


def main() -> int:
    settings = SETTINGS_FILE.read_text(encoding="utf-8")
    configuration = CONFIGURATION_FILE.read_text(encoding="utf-8")
    download_manager = DOWNLOAD_MANAGER_FILE.read_text(encoding="utf-8")
    sync_manager = SYNC_MANAGER_FILE.read_text(encoding="utf-8")
    errors: list[str] = []

    settings_configuration_calls = re.findall(
        r"Configuration\.([A-Za-z][A-Za-z0-9_]*)\(\)", settings
    )
    expected_settings_calls = [SAFE_CONFIGURATION_METHOD]
    if settings_configuration_calls != expected_settings_calls:
        errors.append(
            "the remove-downloads settings action must call only "
            f"Configuration.{SAFE_CONFIGURATION_METHOD}(); found "
            f"{settings_configuration_calls!r}"
        )

    broad_clear = function_body(configuration, "clearAllCache") or ""
    sync_clear = function_body(sync_manager, "clearAllCache") or ""
    if (
        "clearAllCache" in settings_configuration_calls
        and "SyncManager.clearAllCache()" in broad_clear
        and "localInputStorage?.removeAll()" in sync_clear
    ):
        errors.append(
            "unsafe path confirmed: Settings remove downloads -> "
            "Configuration.clearAllCache -> SyncManager.clearAllCache -> "
            "localInputStorage.removeAll"
        )

    safe_clear = function_body(configuration, SAFE_CONFIGURATION_METHOD)
    if safe_clear is None:
        errors.append(
            f"Configuration.{SAFE_CONFIGURATION_METHOD}() is missing"
        )
    else:
        for forbidden in ("APICache.", "SyncManager."):
            if forbidden in safe_clear:
                errors.append(
                    f"Configuration.{SAFE_CONFIGURATION_METHOD}() reaches shared "
                    f"storage through {forbidden}"
                )

        for forbidden in re.findall(
            r"\b[A-Za-z][A-Za-z0-9_]*\.clearAllCache\(\)", safe_clear
        ):
            errors.append(
                f"Configuration.{SAFE_CONFIGURATION_METHOD}() reaches shared "
                f"storage through {forbidden}"
            )

        for required in (
            "DownloadManager.clearInMemoryDownloads()",
            "Downloader.removeAllDownloadedFiles()",
        ):
            if required not in safe_clear:
                errors.append(
                    f"Configuration.{SAFE_CONFIGURATION_METHOD}() must call {required}"
                )

    memory_clear = function_body(download_manager, SAFE_DOWNLOAD_MANAGER_METHOD)
    if memory_clear is None:
        errors.append(
            f"DownloadManager.{SAFE_DOWNLOAD_MANAGER_METHOD}() is missing"
        )
    else:
        for forbidden in (
            "APICache.",
            "downloadManagerStorage",
            "downloadManagerKeys",
            ".removeAll(",
            ".removeObject(",
            ".setObject(",
        ):
            if forbidden in memory_clear:
                errors.append(
                    f"DownloadManager.{SAFE_DOWNLOAD_MANAGER_METHOD}() must be "
                    f"memory-only; found {forbidden}"
                )

        for required in ("downloadItems = [:]", "downloadKeys = []"):
            if required not in memory_clear:
                errors.append(
                    f"DownloadManager.{SAFE_DOWNLOAD_MANAGER_METHOD}() must reset "
                    f"{required}"
                )

    if errors:
        print("Remove-downloads preservation validation failed:", file=sys.stderr)
        for error in errors:
            print(f" - {error}", file=sys.stderr)
        return 1

    print(
        "Remove-downloads preservation validation passed: no shared user-input "
        "storage mutation is reachable from the settings action."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
