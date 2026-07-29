#!/usr/bin/env python3
"""Regression checks for document-scoped PDF annotation restoration.

This repository has no XCTest target and the audit host does not provide Xcode.
The tests below therefore exercise an executable model of the restore contract and
also pin the safety-critical structure of the production Swift implementation.
"""

from __future__ import annotations

import dataclasses
import json
import os
import pathlib
import subprocess
import unittest
from typing import Iterable


ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "Sabbath School/View/Segment/PDFAuxiliary/PDFAuxiliaryView.swift"
CONTROLLER_SOURCE_PATH = (
    ROOT / "Sabbath School/View/Segment/PDFAuxiliary/PDFAuxiliaryViewController.swift"
)


def load_production_source(path: pathlib.Path) -> str:
    """Load the working tree, or a Git ref supplied for regression replay."""

    source_ref = os.environ.get("PDF_ANNOTATION_RESTORE_SOURCE_REF")
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
class PageSnapshot:
    page_index: int
    annotations: tuple[str, ...]


@dataclasses.dataclass(frozen=True)
class Snapshot:
    pdf_id: str
    block_id: str
    timestamp: int
    pages: tuple[PageSnapshot, ...]


class RestoreModel:
    """Small executable specification mirrored by the Swift coordinator."""

    def __init__(self, documents: dict[str, list[dict[str, object]]]) -> None:
        self.documents = documents
        self.accepted: dict[str, Snapshot] = {}
        self.dirty: set[str] = set()

    def mark_dirty(self, pdf_id: str) -> None:
        if pdf_id in self.documents:
            self.dirty.add(pdf_id)

    def record_local(self, snapshot: Snapshot) -> None:
        self.accepted[snapshot.pdf_id] = snapshot
        self.dirty.discard(snapshot.pdf_id)

    def restore(self, inputs: Iterable[object]) -> None:
        candidates: dict[str, Snapshot] = {}
        ambiguous: set[str] = set()

        for value in inputs:
            if (
                not isinstance(value, Snapshot)
                or value.block_id != value.pdf_id
                or value.pdf_id not in self.documents
            ):
                continue

            existing = candidates.get(value.pdf_id)
            if existing is None or value.timestamp > existing.timestamp:
                candidates[value.pdf_id] = value
                ambiguous.discard(value.pdf_id)
            elif value.timestamp == existing.timestamp and value.pages != existing.pages:
                ambiguous.add(value.pdf_id)

        for pdf_id, candidate in candidates.items():
            if pdf_id in ambiguous or pdf_id in self.dirty:
                continue

            accepted = self.accepted.get(pdf_id)
            if accepted is not None:
                if candidate.timestamp < accepted.timestamp:
                    continue
                if candidate.timestamp == accepted.timestamp:
                    # Equal versions are either an echo or an unorderable conflict.
                    continue

            try:
                replacement = self._stage(candidate)
            except (TypeError, ValueError, json.JSONDecodeError):
                continue

            # The swap happens only after every annotation in this PDF validates.
            self.documents[pdf_id] = replacement
            self.accepted[pdf_id] = candidate

    @staticmethod
    def _stage(snapshot: Snapshot) -> list[dict[str, object]]:
        replacement: list[dict[str, object]] = []
        seen_pages: set[int] = set()

        for page in snapshot.pages:
            if page.page_index < 0 or page.page_index >= 100:
                raise ValueError("page outside document")
            if page.page_index in seen_pages:
                raise ValueError("duplicate page")
            seen_pages.add(page.page_index)

            for serialized in page.annotations:
                decoded = json.loads(serialized)
                if not isinstance(decoded, dict):
                    raise TypeError("annotation must be an object")
                if decoded.get("pageIndex") != page.page_index:
                    raise ValueError("annotation belongs to another page")
                replacement.append(decoded)

        return replacement


def annotation(annotation_id: str, page_index: int = 0) -> str:
    return json.dumps({"id": annotation_id, "pageIndex": page_index}, sort_keys=True)


def snapshot(pdf_id: str, timestamp: int, *annotation_ids: str) -> Snapshot:
    return Snapshot(
        pdf_id=pdf_id,
        block_id=pdf_id,
        timestamp=timestamp,
        pages=(PageSnapshot(0, tuple(annotation(value) for value in annotation_ids)),),
    )


class RestoreContractTests(unittest.TestCase):
    def test_unrelated_emissions_do_not_clear_any_pdf(self) -> None:
        model = RestoreModel({"pdf-a": [{"id": "a"}], "pdf-b": [{"id": "b"}]})

        model.restore([{"type": "comment"}, snapshot("pdf-c", 2, "c")])

        self.assertEqual(model.documents["pdf-a"], [{"id": "a"}])
        self.assertEqual(model.documents["pdf-b"], [{"id": "b"}])

    def test_matching_update_swaps_only_its_document(self) -> None:
        model = RestoreModel({"pdf-a": [{"id": "old-a"}], "pdf-b": [{"id": "old-b"}]})

        model.restore([snapshot("pdf-a", 2, "new-a")])

        self.assertEqual(model.documents["pdf-a"], [{"id": "new-a", "pageIndex": 0}])
        self.assertEqual(model.documents["pdf-b"], [{"id": "old-b"}])

    def test_malformed_snapshot_preserves_last_known_good(self) -> None:
        model = RestoreModel({"pdf-a": [{"id": "visible"}]})
        malformed = Snapshot("pdf-a", "pdf-a", 3, (PageSnapshot(0, ("not-json",)),))

        model.restore([malformed])

        self.assertEqual(model.documents["pdf-a"], [{"id": "visible"}])
        self.assertNotIn("pdf-a", model.accepted)

    def test_one_malformed_pdf_does_not_block_an_independent_valid_pdf(self) -> None:
        model = RestoreModel({"pdf-a": [{"id": "old-a"}], "pdf-b": [{"id": "old-b"}]})
        malformed = Snapshot("pdf-a", "pdf-a", 3, (PageSnapshot(0, ("not-json",)),))

        model.restore([malformed, snapshot("pdf-b", 3, "new-b")])

        self.assertEqual(model.documents["pdf-a"], [{"id": "old-a"}])
        self.assertEqual(model.documents["pdf-b"], [{"id": "new-b", "pageIndex": 0}])

    def test_dirty_document_rejects_remote_replacement(self) -> None:
        model = RestoreModel({"pdf-a": [{"id": "local-unsaved"}]})
        model.mark_dirty("pdf-a")

        model.restore([snapshot("pdf-a", 20, "remote")])

        self.assertEqual(model.documents["pdf-a"], [{"id": "local-unsaved"}])

    def test_stale_and_equal_conflicting_versions_preserve_newer_local_snapshot(self) -> None:
        local = snapshot("pdf-a", 20, "local")
        model = RestoreModel({"pdf-a": [{"id": "local", "pageIndex": 0}]})
        model.record_local(local)

        model.restore([snapshot("pdf-a", 19, "stale")])
        model.restore([snapshot("pdf-a", 20, "same-second-conflict")])

        self.assertEqual(model.documents["pdf-a"], [{"id": "local", "pageIndex": 0}])

    def test_explicit_empty_snapshot_clears_only_matching_pdf(self) -> None:
        model = RestoreModel({"pdf-a": [{"id": "a"}], "pdf-b": [{"id": "b"}]})

        model.restore([Snapshot("pdf-a", "pdf-a", 2, ())])

        self.assertEqual(model.documents["pdf-a"], [])
        self.assertEqual(model.documents["pdf-b"], [{"id": "b"}])

    def test_duplicate_page_and_page_mismatch_are_rejected_before_swap(self) -> None:
        duplicate_page = Snapshot(
            "pdf-a",
            "pdf-a",
            2,
            (PageSnapshot(0, (annotation("one"),)), PageSnapshot(0, (annotation("two"),))),
        )
        mismatch = Snapshot(
            "pdf-a",
            "pdf-a",
            3,
            (PageSnapshot(1, (annotation("wrong", 0),)),),
        )

        for malformed in (duplicate_page, mismatch):
            with self.subTest(malformed=malformed):
                model = RestoreModel({"pdf-a": [{"id": "visible"}]})
                model.restore([malformed])
                self.assertEqual(model.documents["pdf-a"], [{"id": "visible"}])

    def test_cross_id_snapshot_is_rejected_without_mutation(self) -> None:
        model = RestoreModel({"pdf-a": [{"id": "visible-a"}], "pdf-b": [{"id": "visible-b"}]})
        cross_id = Snapshot(
            pdf_id="pdf-a",
            block_id="pdf-b",
            timestamp=4,
            pages=(PageSnapshot(0, (annotation("wrong-document"),)),),
        )

        model.restore([cross_id])

        self.assertEqual(model.documents["pdf-a"], [{"id": "visible-a"}])
        self.assertEqual(model.documents["pdf-b"], [{"id": "visible-b"}])
        self.assertNotIn("pdf-a", model.accepted)


class ProductionSourceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.source = load_production_source(SOURCE_PATH)
        cls.controller_source = load_production_source(CONTROLLER_SOURCE_PATH)

    def test_restore_is_coordinator_scoped_and_tracks_dirty_documents(self) -> None:
        self.assertIn("PDFAnnotationRestoreState", self.source)
        self.assertIn("markDirty(pdfId:", self.source)
        self.assertIn("recordLocalSnapshot", self.source)
        self.assertIn(".PSPDFAnnotationsAdded", self.source)
        self.assertIn(".PSPDFAnnotationsRemoved", self.source)
        self.assertIn(".PSPDFAnnotationChanged", self.source)

    def test_controller_does_not_retain_its_coordinator_delegate(self) -> None:
        self.assertIn("protocol PDFAuxiliaryViewControllerDelegate: AnyObject", self.controller_source)
        self.assertIn(
            "weak var pdfAuxiliaryViewControllerDelegate: PDFAuxiliaryViewControllerDelegate?",
            self.controller_source,
        )

    def test_restore_stages_and_validates_before_document_mutation(self) -> None:
        stage_call = self.source.index("stageReplacement(for:")
        remove_call = self.source.index("document.remove(annotations:", stage_call)
        self.assertLess(stage_call, remove_call)
        self.assertIn("seenPageIndices.insert", self.source)
        self.assertIn("Int(decodedAnnotation.pageIndex) == pageSnapshot.pageIndex", self.source)

    def test_sdk_swap_failures_attempt_to_restore_the_previous_snapshot(self) -> None:
        self.assertIn(
            "guard document.remove(annotations: currentAnnotations, options: .none)",
            self.source,
        )
        self.assertIn("guard document.add(annotations: replacement, options: nil)", self.source)
        self.assertIn("restoreOriginalAnnotations(currentAnnotations, in: document)", self.source)
        self.assertIn("PDFAnnotationRestoreError.rollbackFailed", self.source)

    def test_restore_has_no_forced_utf8_or_instant_json_decoding(self) -> None:
        self.assertNotIn("data(using: .utf8)!", self.source)
        self.assertNotIn("try!", self.source)
        restore_start = self.source.index("func stageReplacement(")
        restore_end = self.source.index("func saveUserInput(", restore_start)
        restore_source = self.source[restore_start:restore_end]
        self.assertNotIn("try!", restore_source)
        self.assertIn("guard let annotationData = serializedAnnotation.data(using: .utf8)", restore_source)

    def test_global_annotation_wipe_pattern_is_removed(self) -> None:
        self.assertNotIn("documents.forEach { document in", self.source)
        self.assertIn("guard let target = restoreTarget(for: candidate.pdfId)", self.source)

    def test_restore_rejects_cross_id_annotation_records(self) -> None:
        self.assertIn("candidate.blockId == candidate.pdfId", self.source)


if __name__ == "__main__":
    unittest.main(verbosity=2)
