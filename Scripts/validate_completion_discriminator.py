#!/usr/bin/env python3
"""Regression checks for legacy completion-discriminator compatibility.

The repository has no runnable unit-test target and this audit host has no
Xcode. These checks exercise versioned JSON fixtures through an executable
decode/encode/keying model and pin the corresponding production Swift branches.
Set COMPLETION_DISCRIMINATOR_SOURCE_REF to replay source contracts against a Git
ref such as the audited base commit.
"""

from __future__ import annotations

import dataclasses
import json
import os
import pathlib
import subprocess
import unittest
from typing import Any


ROOT = pathlib.Path(__file__).resolve().parents[1]
FIXTURE_PATH = ROOT / "Scripts/fixtures/completion_discriminator_cases.json"
ANY_INPUT_PATH = ROOT / "Sabbath School/Common/Model/AnyUserInput.swift"
COMPLETION_VIEW_PATH = (
    ROOT / "Sabbath School/View/Segment/ResourceCompletionView.swift"
)
INLINE_TEXT_PATH = (
    ROOT / "Sabbath School/View/Segment/Blocks/InlineAttributedText.swift"
)
SYNC_MANAGER_PATH = ROOT / "Sabbath School/Common/Configuration/SyncManager.swift"
DOCUMENT_VIEW_MODEL_PATH = (
    ROOT / "Sabbath School/View/Document/DocumentViewModel.swift"
)


def load_production_source(path: pathlib.Path) -> str:
    """Load the working tree, or a Git ref supplied for regression replay."""

    source_ref = os.environ.get("COMPLETION_DISCRIMINATOR_SOURCE_REF")
    if source_ref:
        relative_path = path.relative_to(ROOT).as_posix()
        return subprocess.check_output(
            ["git", "show", f"{source_ref}:{relative_path}"],
            cwd=ROOT,
            text=True,
            encoding="utf-8",
        )
    return path.read_text(encoding="utf-8")


@dataclasses.dataclass(frozen=True)
class DecodedInput:
    block_id: str
    input_type: str
    timestamp: int
    value: str | dict[str, str]


class PayloadError(ValueError):
    pass


def require_base_fields(payload: dict[str, Any]) -> tuple[str, str, int]:
    try:
        block_id = payload["blockId"]
        input_type = payload["inputType"]
        timestamp = payload["timestamp"]
    except KeyError as error:
        raise PayloadError(f"missing {error.args[0]}") from error

    if not isinstance(block_id, str) or not isinstance(input_type, str):
        raise PayloadError("invalid identity/discriminator")
    if not isinstance(timestamp, int) or isinstance(timestamp, bool):
        raise PayloadError("invalid timestamp")
    return block_id, input_type, timestamp


def decode_current(payload: dict[str, Any]) -> DecodedInput:
    """Executable specification for the backward-compatible Swift dispatcher."""

    block_id, input_type, timestamp = require_base_fields(payload)

    if input_type == "comment":
        # v0 nested-completion writes used "comment" but had no comment field.
        if "completion" in payload and "comment" not in payload:
            completion = payload["completion"]
            if not isinstance(completion, dict) or not all(
                isinstance(key, str) and isinstance(value, str)
                for key, value in completion.items()
            ):
                raise PayloadError("invalid legacy completion")
            return DecodedInput(block_id, "completion", timestamp, completion)

        comment = payload.get("comment")
        if not isinstance(comment, str):
            raise PayloadError("invalid comment")
        return DecodedInput(block_id, "comment", timestamp, comment)

    if input_type == "completion":
        completion = payload.get("completion")
        if not isinstance(completion, dict) or not all(
            isinstance(key, str) and isinstance(value, str)
            for key, value in completion.items()
        ):
            raise PayloadError("invalid completion")
        return DecodedInput(block_id, "completion", timestamp, completion)

    raise PayloadError("unsupported fixture discriminator")


def decode_base(payload: dict[str, Any]) -> DecodedInput:
    """The audited base dispatches only on inputType and cannot read v0."""

    block_id, input_type, timestamp = require_base_fields(payload)
    if input_type == "comment":
        comment = payload.get("comment")
        if not isinstance(comment, str):
            raise PayloadError("base selected UserInputComment without comment")
        return DecodedInput(block_id, "comment", timestamp, comment)
    if input_type == "completion":
        completion = payload.get("completion")
        if not isinstance(completion, dict):
            raise PayloadError("invalid completion")
        return DecodedInput(block_id, "completion", timestamp, completion)
    raise PayloadError("unsupported fixture discriminator")


def encode_current(value: DecodedInput) -> dict[str, Any]:
    encoded: dict[str, Any] = {
        "blockId": value.block_id,
        "inputType": value.input_type,
        "timestamp": value.timestamp,
    }
    if value.input_type == "completion":
        encoded["completion"] = value.value
    elif value.input_type == "comment":
        encoded["comment"] = value.value
    else:
        raise PayloadError("unsupported value")
    return encoded


def storage_key(value: DecodedInput) -> tuple[str, str]:
    return value.block_id, value.input_type


def raw_storage_key(payload: dict[str, Any]) -> tuple[str, str]:
    block_id, input_type, _ = require_base_fields(payload)
    return block_id, input_type


class CompletionDiscriminatorModelTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.fixtures = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))

    def test_fixture_version_is_explicit(self) -> None:
        self.assertEqual(self.fixtures["fixtureVersion"], 1)

    def test_audited_base_cannot_decode_legacy_completion_shape(self) -> None:
        with self.assertRaisesRegex(
            PayloadError,
            "selected UserInputComment without comment",
        ):
            decode_base(self.fixtures["legacyCompletion"])

    def test_audited_base_keying_collides_with_real_comment(self) -> None:
        self.assertEqual(
            raw_storage_key(self.fixtures["legacyCompletion"]),
            raw_storage_key(self.fixtures["currentComment"]),
        )

    def test_legacy_completion_decodes_and_reencodes_canonically(self) -> None:
        decoded = decode_current(self.fixtures["legacyCompletion"])

        self.assertEqual(decoded.input_type, "completion")
        self.assertEqual(
            encode_current(decoded),
            self.fixtures["currentCompletion"],
        )

    def test_current_completion_round_trip_is_unchanged(self) -> None:
        payload = self.fixtures["currentCompletion"]
        self.assertEqual(encode_current(decode_current(payload)), payload)

    def test_current_comment_round_trip_is_unchanged(self) -> None:
        payload = self.fixtures["currentComment"]
        self.assertEqual(encode_current(decode_current(payload)), payload)

    def test_real_comment_wins_when_both_shape_keys_are_present(self) -> None:
        ambiguous = dict(self.fixtures["currentComment"])
        ambiguous["completion"] = {"blank-1": "ignored"}

        decoded = decode_current(ambiguous)

        self.assertEqual(decoded.input_type, "comment")
        self.assertEqual(decoded.value, "synthetic comment")

    def test_normalized_completion_and_comment_have_distinct_storage_keys(self) -> None:
        completion = decode_current(self.fixtures["legacyCompletion"])
        comment = decode_current(self.fixtures["currentComment"])

        self.assertNotEqual(storage_key(completion), storage_key(comment))
        self.assertEqual(
            {storage_key(completion), storage_key(comment)},
            {
                ("synthetic-modal-block", "completion"),
                ("synthetic-modal-block", "comment"),
            },
        )

    def test_mixed_legacy_cache_array_keeps_both_records(self) -> None:
        legacy_cache = [
            {
                "id": "synthetic-completion-row",
                "synced": False,
                "userInput": self.fixtures["legacyCompletion"],
            },
            {
                "id": "synthetic-comment-row",
                "synced": True,
                "userInput": self.fixtures["currentComment"],
            },
        ]

        decoded = [decode_current(row["userInput"]) for row in legacy_cache]

        self.assertEqual(len({storage_key(value) for value in decoded}), 2)
        self.assertEqual(
            [encode_current(value)["inputType"] for value in decoded],
            ["completion", "comment"],
        )

    def test_unsynced_legacy_retry_uses_canonical_endpoint_and_body(self) -> None:
        decoded = decode_current(self.fixtures["legacyCompletion"])
        endpoint = (
            "/resources/user/input/"
            f"{decoded.input_type}/document/{decoded.block_id}"
        )

        self.assertIn("/completion/", endpoint)
        self.assertEqual(encode_current(decoded)["inputType"], "completion")

    def test_malformed_legacy_completion_is_rejected(self) -> None:
        malformed = dict(self.fixtures["legacyCompletion"])
        malformed["completion"] = {"blank-1": 7}

        with self.assertRaisesRegex(PayloadError, "invalid legacy completion"):
            decode_current(malformed)


class ProductionSourceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.any_input = load_production_source(ANY_INPUT_PATH)
        cls.completion_view = load_production_source(COMPLETION_VIEW_PATH)
        cls.inline_text = load_production_source(INLINE_TEXT_PATH)
        cls.sync_manager = load_production_source(SYNC_MANAGER_PATH)
        cls.document_view_model = load_production_source(DOCUMENT_VIEW_MODEL_PATH)

    def test_dispatcher_recognizes_only_the_unambiguous_legacy_shape(self) -> None:
        self.assertIn("case comment", self.any_input)
        self.assertIn("case completion", self.any_input)
        self.assertIn("container.contains(.completion)", self.any_input)
        self.assertIn("!container.contains(.comment)", self.any_input)

        comment_case = self.any_input.index("case .comment:")
        current_completion_case = self.any_input.index("case .completion:")
        branch = self.any_input[comment_case:current_completion_case]
        legacy_decode = branch.index("UserInputCompletion(from: decoder)")
        comment_decode = branch.index("UserInputComment(from: decoder)")
        self.assertLess(legacy_decode, comment_decode)

    def test_legacy_decode_normalizes_identity_before_keying_or_retry(self) -> None:
        self.assertIn("let legacyCompletion", self.any_input)
        self.assertIn("inputType: .completion", self.any_input)
        self.assertIn("completion: legacyCompletion.completion", self.any_input)
        self.assertIn("timestamp: legacyCompletion.timestamp", self.any_input)
        self.assertIn(
            "$0.userInput.blockId == userInput.blockId && "
            "$0.userInput.inputType == userInput.inputType",
            self.sync_manager,
        )
        self.assertIn(
            "localUserInput.userInput.inputType.rawValue",
            self.document_view_model,
        )

    def test_new_nested_completion_writes_use_canonical_discriminator(self) -> None:
        self.assertNotIn(
            "UserInputCompletion(blockId: blockId, inputType: .comment",
            self.completion_view,
        )
        self.assertIn(
            "UserInputCompletion(blockId: blockId, inputType: .completion",
            self.completion_view,
        )

    def test_existing_primary_completion_writes_remain_canonical(self) -> None:
        self.assertIn(
            "UserInputCompletion(blockId: block.id, inputType: .completion",
            self.inline_text,
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
