#!/usr/bin/env python3
"""Validate the canonical Nuke Swift Package Manager reference."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from urllib.parse import urlsplit


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
PROJECT_FILE = REPOSITORY_ROOT / "Sabbath School.xcodeproj" / "project.pbxproj"
RESOLVED_FILE = (
    REPOSITORY_ROOT
    / "Sabbath School.xcodeproj"
    / "project.xcworkspace"
    / "xcshareddata"
    / "swiftpm"
    / "Package.resolved"
)

NUKE_URL = "https://github.com/kean/Nuke.git"
NUKE_IDENTITY = "nuke"
NUKE_REVISION = "0ead44350d2737db384908569c012fe67c421e4d"
NUKE_VERSION = "12.8.0"


def is_nuke_location(value: object) -> bool:
    if not isinstance(value, str):
        return False

    parsed = urlsplit(value)
    path = parsed.path.rstrip("/")
    if path.lower().endswith(".git"):
        path = path[:-4]
    return parsed.netloc.lower() == "github.com" and path.lower() == "/kean/nuke"


def main() -> int:
    errors: list[str] = []

    project = PROJECT_FILE.read_text(encoding="utf-8")
    repository_urls = re.findall(r'repositoryURL = "([^"]+)";', project)
    project_nuke_urls = [url for url in repository_urls if is_nuke_location(url)]
    if project_nuke_urls != [NUKE_URL]:
        errors.append(
            f"{PROJECT_FILE.relative_to(REPOSITORY_ROOT)} must reference Nuke once as "
            f"{NUKE_URL!r}; found {project_nuke_urls!r}"
        )

    resolved = json.loads(RESOLVED_FILE.read_text(encoding="utf-8"))
    pins = resolved.get("pins", [])
    nuke_pins = [
        pin
        for pin in pins
        if isinstance(pin, dict)
        and (
            str(pin.get("identity", "")).partition("?")[0].lower() == NUKE_IDENTITY
            or is_nuke_location(pin.get("location"))
        )
    ]

    if len(nuke_pins) != 1:
        errors.append(
            f"{RESOLVED_FILE.relative_to(REPOSITORY_ROOT)} must contain exactly one "
            f"Nuke pin; found {len(nuke_pins)}"
        )
    else:
        pin = nuke_pins[0]
        state = pin.get("state", {})
        expected_values = {
            "identity": (pin.get("identity"), NUKE_IDENTITY),
            "location": (pin.get("location"), NUKE_URL),
            "revision": (state.get("revision"), NUKE_REVISION),
            "version": (state.get("version"), NUKE_VERSION),
        }
        for field, (actual, expected) in expected_values.items():
            if actual != expected:
                errors.append(
                    f"Nuke {field} must remain {expected!r}; found {actual!r}"
                )

    if errors:
        print("Swift package reference validation failed:", file=sys.stderr)
        for error in errors:
            print(f" - {error}", file=sys.stderr)
        return 1

    print(
        f"Swift package reference validation passed: Nuke {NUKE_VERSION} "
        f"at {NUKE_REVISION}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
