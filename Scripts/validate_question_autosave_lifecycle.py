#!/usr/bin/env python3
"""Regression checks for lifecycle-safe debounced user-input persistence.

The repository does not contain an XCTest target and the audit host does not
provide Xcode. These checks therefore combine an executable fake-clock model of
the debounce contract with source-contract checks for the production Swift
implementation. Set QUESTION_AUTOSAVE_SOURCE_REF to replay the source checks
against a Git ref (for example, the audited base commit).
"""

from __future__ import annotations

import heapq
import os
import pathlib
import subprocess
import unittest
from collections.abc import Callable
from dataclasses import dataclass, field
from typing import Any


ROOT = pathlib.Path(__file__).resolve().parents[1]
INTERACTIVE_SOURCE_PATH = (
    ROOT / "Sabbath School/View/Segment/Blocks/InteractiveBlock.swift"
)
QUESTION_SOURCE_PATH = (
    ROOT / "Sabbath School/View/Segment/Blocks/BlockQuestionView.swift"
)
COMPLETION_SOURCE_PATH = (
    ROOT / "Sabbath School/View/Segment/ResourceCompletionView.swift"
)


def load_production_source(path: pathlib.Path) -> str:
    """Load the working tree, or a Git ref supplied for regression replay."""

    source_ref = os.environ.get("QUESTION_AUTOSAVE_SOURCE_REF")
    if source_ref:
        relative_path = path.relative_to(ROOT).as_posix()
        return subprocess.check_output(
            ["git", "show", f"{source_ref}:{relative_path}"],
            cwd=ROOT,
            text=True,
            encoding="utf-8",
        )
    return path.read_text(encoding="utf-8")


@dataclass(order=True)
class ScheduledCall:
    deadline: float
    order: int
    callback: Callable[[], None] = field(compare=False)
    cancelled: bool = field(default=False, compare=False)


class FakeClock:
    """Deterministic scheduler used to exercise lifecycle timing races."""

    def __init__(self) -> None:
        self.now = 0.0
        self._next_order = 0
        self._calls: list[ScheduledCall] = []

    def schedule(self, delay: float, callback: Callable[[], None]) -> ScheduledCall:
        call = ScheduledCall(self.now + delay, self._next_order, callback)
        self._next_order += 1
        heapq.heappush(self._calls, call)
        return call

    @staticmethod
    def cancel(call: ScheduledCall | None) -> None:
        if call is not None:
            call.cancelled = True

    def advance(self, interval: float) -> None:
        target = self.now + interval
        while self._calls and self._calls[0].deadline <= target:
            call = heapq.heappop(self._calls)
            self.now = call.deadline
            if not call.cancelled:
                call.callback()
        self.now = target


class PendingSave:
    """Executable specification mirrored by PendingUserInputSave in Swift."""

    def __init__(self, clock: FakeClock) -> None:
        self.clock = clock
        self._timer: ScheduledCall | None = None
        self._pending: Callable[[], None] | None = None

    @property
    def has_pending(self) -> bool:
        return self._pending is not None

    def schedule(self, delay: float, save: Callable[[], None]) -> None:
        self.clock.cancel(self._timer)
        self._pending = save
        self._timer = self.clock.schedule(delay, self.flush)

    def flush(self) -> bool:
        self.clock.cancel(self._timer)
        self._timer = None
        pending = self._pending
        self._pending = None
        if pending is None:
            return False
        pending()
        return True


class EditableField:
    """Field state that refuses persisted echoes while its edit is pending."""

    def __init__(
        self,
        clock: FakeClock,
        store: "DurableInputStore",
        field_id: str,
        value: str,
    ) -> None:
        self.clock = clock
        self.store = store
        self.field_id = field_id
        self.value = value
        self.pending = PendingSave(clock)

    def edit(self, value: str, delay: float) -> None:
        self.value = value
        self.pending.schedule(
            delay,
            lambda: self.store.save("doc", self.field_id, value),
        )

    def receive_persisted(self, value: str) -> None:
        if not self.pending.has_pending:
            self.value = value


class DurableInputStore:
    """Minimal document/field upsert model for restart and offline checks."""

    def __init__(self) -> None:
        self.values: dict[tuple[str, str], str] = {}
        self.unsynced: set[tuple[str, str]] = set()
        self.write_count = 0

    def save(self, document_id: str, field_id: str, value: str) -> None:
        key = (document_id, field_id)
        self.values[key] = value
        self.unsynced.add(key)
        self.write_count += 1


class PendingSaveModelTests(unittest.TestCase):
    def test_navigation_inside_debounce_flushes_latest_value_immediately(self) -> None:
        clock = FakeClock()
        store = DurableInputStore()
        pending = PendingSave(clock)

        pending.schedule(1.0, lambda: store.save("doc", "question", "latest"))
        clock.advance(0.2)
        self.assertTrue(pending.flush())

        self.assertEqual(store.values[("doc", "question")], "latest")
        self.assertEqual(store.write_count, 1)

    def test_background_flush_is_idempotent_with_later_timer_and_disappear(self) -> None:
        clock = FakeClock()
        store = DurableInputStore()
        pending = PendingSave(clock)

        pending.schedule(1.0, lambda: store.save("doc", "question", "answer"))
        self.assertTrue(pending.flush())  # scene becomes inactive
        self.assertFalse(pending.flush())  # view then disappears
        clock.advance(2.0)  # invalidated timer must not save again

        self.assertEqual(store.write_count, 1)

    def test_alternating_fields_have_independent_debounce_ownership(self) -> None:
        clock = FakeClock()
        store = DurableInputStore()
        first = EditableField(clock, store, "question-a", "old-one")
        second = EditableField(clock, store, "question-b", "old-two")

        first.edit("one", 1.0)
        clock.advance(0.4)
        second.edit("two", 1.0)
        clock.advance(0.6)

        # The first field's publication contains B's old durable value. B must
        # keep its unsaved edit rather than reschedule that stale echo.
        second.receive_persisted("old-two")
        self.assertEqual(store.values[("doc", "question-a")], "one")
        self.assertNotIn(("doc", "question-b"), store.values)
        self.assertEqual(second.value, "two")

        clock.advance(0.4)
        self.assertEqual(store.values[("doc", "question-b")], "two")

    def test_rescheduling_persists_only_the_latest_edit(self) -> None:
        clock = FakeClock()
        store = DurableInputStore()
        pending = PendingSave(clock)

        pending.schedule(1.0, lambda: store.save("doc", "question", "old"))
        clock.advance(0.5)
        pending.schedule(1.0, lambda: store.save("doc", "question", "new"))
        clock.advance(0.5)
        self.assertEqual(store.write_count, 0)

        clock.advance(0.5)
        self.assertEqual(store.values[("doc", "question")], "new")
        self.assertEqual(store.write_count, 1)

    def test_lifecycle_flush_survives_restart_while_offline(self) -> None:
        clock = FakeClock()
        store = DurableInputStore()
        pending = PendingSave(clock)

        pending.schedule(2.0, lambda: store.save("doc", "completion", "typed"))
        clock.advance(0.1)
        pending.flush()  # synchronous local enqueue before process termination

        restarted_values = dict(store.values)
        restarted_unsynced = set(store.unsynced)
        self.assertEqual(restarted_values[("doc", "completion")], "typed")
        self.assertIn(("doc", "completion"), restarted_unsynced)

    def test_new_edit_after_flush_gets_a_new_debounce_window(self) -> None:
        clock = FakeClock()
        saved: list[str] = []
        pending = PendingSave(clock)

        pending.schedule(1.0, lambda: saved.append("first"))
        pending.flush()
        pending.schedule(1.0, lambda: saved.append("second"))
        clock.advance(1.0)

        self.assertEqual(saved, ["first", "second"])


class ProductionSourceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.interactive = load_production_source(INTERACTIVE_SOURCE_PATH)
        cls.question = load_production_source(QUESTION_SOURCE_PATH)
        cls.completion = load_production_source(COMPLETION_SOURCE_PATH)

    def test_shared_pending_save_clears_ownership_before_callback(self) -> None:
        self.assertIn("final class PendingUserInputSave: ObservableObject", self.interactive)
        flush_start = self.interactive.index("func flush() -> Bool")
        flush_end = self.interactive.index("deinit", flush_start)
        flush_source = self.interactive[flush_start:flush_end]
        clear_index = flush_source.index("pendingSave = nil")
        callback_index = flush_source.index("save()")
        self.assertLess(clear_index, callback_index)
        self.assertIn("[weak self]", self.interactive)

    def test_question_uses_view_owned_coordinator_not_view_local_timer(self) -> None:
        self.assertIn(
            "@StateObject private var pendingSave = PendingUserInputSave()",
            self.question,
        )
        self.assertNotIn("@State private var typingTimer", self.question)
        self.assertNotIn("Timer.scheduledTimer", self.question)
        self.assertIn("scheduleAnswerSave(newValue)", self.question)
        self.assertIn("guard !pendingSave.hasPendingSave", self.question)

    def test_question_flushes_on_navigation_and_scene_inactivation(self) -> None:
        self.assertIn("@Environment(\\.scenePhase)", self.question)
        self.assertIn(".onDisappear", self.question)
        self.assertIn("if newPhase != .active", self.question)
        self.assertGreaterEqual(self.question.count("flushPendingSave()"), 2)
        self.assertIn("let documentId = viewModel.document?.id", self.question)
        self.assertIn("documentId: documentId", self.question)

    def test_completion_uses_same_coordinator_not_view_local_timer(self) -> None:
        self.assertIn(
            "@StateObject private var pendingSave = PendingUserInputSave()",
            self.completion,
        )
        self.assertNotIn("@State private var typingTimer", self.completion)
        self.assertNotIn("Timer.scheduledTimer", self.completion)
        self.assertIn("scheduleCompletionSave(newValue)", self.completion)

    def test_completion_flushes_before_dismiss_and_on_scene_inactivation(self) -> None:
        self.assertIn("@Environment(\\.scenePhase)", self.completion)
        self.assertIn(".onDisappear", self.completion)
        self.assertIn("if newPhase != .active", self.completion)
        self.assertGreaterEqual(self.completion.count("flushPendingSave()"), 4)
        self.assertIn(
            "let documentId = documentViewModel.document?.id",
            self.completion,
        )
        self.assertIn("documentId: documentId", self.completion)

    def test_payload_schema_and_existing_local_persistence_entrypoint_are_preserved(self) -> None:
        self.assertIn("UserInputQuestion(", self.question)
        self.assertIn("inputType: .question", self.question)
        self.assertIn("UserInputCompletion(", self.completion)
        self.assertIn("inputType: .completion", self.completion)
        self.assertIn("inputType: .comment", self.completion)
        self.assertIn("userInputType: .completion", self.completion)
        self.assertIn("saveBlockUserInput(", self.question)
        self.assertIn("saveBlockUserInput(", self.completion)

    def test_primary_completion_path_enqueues_directly_without_observer_duplicate(self) -> None:
        self.assertIn("sourceBlockId: block.id", self.completion)
        self.assertIn("paragraphViewModel.savingMode = false", self.completion)
        direct_path = self.completion.index("if blockId == nil")
        nested_path = self.completion.index(
            "if let blockId = blockId, let documentId = documentId",
            direct_path,
        )
        primary_source = self.completion[direct_path:nested_path]
        self.assertIn("paragraphViewModel.completion = completions", primary_source)
        self.assertIn("viewModel.saveBlockUserInput(", primary_source)
        self.assertIn("blockId: sourceBlockId", primary_source)


if __name__ == "__main__":
    unittest.main(verbosity=2)
