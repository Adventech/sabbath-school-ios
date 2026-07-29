/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SwiftUI
import PSPDFKit
import PSPDFKitUI
import Combine

enum PDFAxiliryViewType {
    case segment
    case aux
}

private enum PDFAnnotationRestoreError: Error {
    case missingDocumentProvider
    case invalidPageIndex
    case duplicatePageIndex
    case invalidAnnotationEncoding
    case mismatchedPageIndex
    case annotationRemovalFailed
    case annotationAdditionFailed
    case rollbackFailed
}

private final class PDFAnnotationRestoreState {
    private var acceptedSnapshots: [String: UserInputAnnotation] = [:]
    private var dirtyPDFIds: Set<String> = []

    func markDirty(pdfId: String) {
        dirtyPDFIds.insert(pdfId)
    }

    func recordLocalSnapshot(_ snapshot: UserInputAnnotation) {
        acceptedSnapshots[snapshot.pdfId] = snapshot
        dirtyPDFIds.remove(snapshot.pdfId)
    }

    func recordRestoredSnapshot(_ snapshot: UserInputAnnotation) {
        acceptedSnapshots[snapshot.pdfId] = snapshot
    }

    func shouldRestore(_ snapshot: UserInputAnnotation) -> Bool {
        guard !dirtyPDFIds.contains(snapshot.pdfId) else {
            return false
        }

        guard let acceptedSnapshot = acceptedSnapshots[snapshot.pdfId] else {
            return true
        }

        // Timestamps have one-second precision. An equal version with different
        // content cannot be ordered safely, so keep the last-known-good snapshot.
        return snapshot.timestamp > acceptedSnapshot.timestamp
    }

    func candidates(
        from documentUserInput: [AnyUserInput],
        matchingPDFIds: Set<String>
    ) -> [UserInputAnnotation] {
        var candidatesByPDFId: [String: UserInputAnnotation] = [:]
        var ambiguousPDFIds: Set<String> = []

        for userInput in documentUserInput where userInput.inputType == .annotation {
            guard let candidate = userInput.asType(UserInputAnnotation.self),
                  candidate.blockId == candidate.pdfId,
                  matchingPDFIds.contains(candidate.pdfId) else {
                continue
            }

            guard let existingCandidate = candidatesByPDFId[candidate.pdfId] else {
                candidatesByPDFId[candidate.pdfId] = candidate
                continue
            }

            if candidate.timestamp > existingCandidate.timestamp {
                candidatesByPDFId[candidate.pdfId] = candidate
                ambiguousPDFIds.remove(candidate.pdfId)
            } else if candidate.timestamp == existingCandidate.timestamp,
                      !Self.hasSamePayload(candidate, existingCandidate) {
                ambiguousPDFIds.insert(candidate.pdfId)
            }
        }

        return candidatesByPDFId.values
            .filter { !ambiguousPDFIds.contains($0.pdfId) && shouldRestore($0) }
            .sorted { $0.pdfId < $1.pdfId }
    }

    private static func hasSamePayload(
        _ lhs: UserInputAnnotation,
        _ rhs: UserInputAnnotation
    ) -> Bool {
        guard lhs.pdfId == rhs.pdfId,
              lhs.data.count == rhs.data.count else {
            return false
        }

        return zip(lhs.data, rhs.data).allSatisfy { lhsPage, rhsPage in
            lhsPage.pageIndex == rhsPage.pageIndex &&
            lhsPage.annotations == rhsPage.annotations
        }
    }
}

struct PDFAuxiliaryViewRepresentable: UIViewControllerRepresentable {
    var pdfs: [PDFAux]
    var viewType: PDFAxiliryViewType = .aux
    var showNavigationBarButtons: Bool = true
    
    @Binding var pdfTabbedViewController: PDFAuxiliaryTabbedViewController?
    
    @EnvironmentObject var viewModel: DocumentViewModel
    
    func getNavbarMaxY() -> CGFloat {
        return UIApplication.shared.currentNavigationController()?.topViewController?.navigationController?.navigationBar.frame.maxY ?? 100
    }
    
    func makeUIViewController(context: Context) -> PDFAuxiliaryTabbedViewController {
        var downloader: Downloader?
        var documents: [Document] = []
        
        for pdf in pdfs {
            let remoteURL = pdf.src
            let fileName = pdf.id
            let destinationFileURL = Helper.PDFDownloadFileURL(fileName: fileName)
            
            let document: Document!
            
            if Helper.PDFDownloadFileExists(fileName: fileName) {
                document = Document(url: destinationFileURL)
            } else {
                downloader = Downloader(remoteURL: remoteURL, destinationFileURL: destinationFileURL)
                let provider = CoordinatedFileDataProvider(fileURL: destinationFileURL, progress: downloader?.progress)
                document = Document(dataProviders: [provider])
            }
            
            document.title = pdf.title
            documents.append(document)
        }
        
        let pdfConfiguration = PDFConfiguration {
            $0.isPageLabelEnabled = false
            $0.documentLabelEnabled = .NO
            $0.allowWindowTitleChange = false
            $0.allowToolbarTitleChange = false
            $0.thumbnailBarMode = .none
            $0.shouldHideStatusBarWithUserInterface = true
            $0.shouldHideNavigationBarWithUserInterface = true
            $0.userInterfaceViewMode = .always
            $0.settingsOptions = [.all]
            $0.useParentNavigationBar = true

            if viewType == .segment {
                // 35 is the height of the tabbar
                let topInset: CGFloat = 35 + getNavbarMaxY()

                $0.additionalContentInsets = .init(top: topInset, left: 0, bottom: 80, right: 0)
            }
            
            $0.pageTransition = Preferences.getPdfPageTransition()
            $0.pageMode = Preferences.getPdfPageMode()
            $0.scrollDirection = Preferences.getPdfScrollDirection()
            $0.spreadFitting = Preferences.getPdfSpreadFitting()
        }
        
        let pdfController = PDFAuxiliaryViewController(document: nil, configuration: pdfConfiguration)
        
        pdfController.pdfAuxiliaryViewControllerDelegate = context.coordinator
        pdfController.viewType = viewType
        pdfController.showNavigationBarButtons = showNavigationBarButtons
        

        pdfController.delegate = context.coordinator
        

        let tabbedPDFController = PDFAuxiliaryTabbedViewController(pdfViewController: pdfController)
        tabbedPDFController.documents = documents
        context.coordinator.tabbedPDFController = tabbedPDFController
        
        DispatchQueue.main.async {
            self.pdfTabbedViewController = tabbedPDFController
            context.coordinator.loadUserInput(documentUserInput: viewModel.documentUserInput)
        }
        
        return tabbedPDFController
    }

    func updateUIViewController(_ uiViewController: PDFAuxiliaryTabbedViewController, context: Context) {
        context.coordinator.parent = self
        context.coordinator.tabbedPDFController = uiViewController
        uiViewController.tabbedBar.frame.origin = CGPoint(x: 0, y: self.viewType == .aux ? 0 : 90)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    class Coordinator: NSObject, PDFViewControllerDelegate, PDFAuxiliaryViewControllerDelegate {
        var parent: PDFAuxiliaryViewRepresentable
        weak var tabbedPDFController: PDFAuxiliaryTabbedViewController?

        private let viewModel: DocumentViewModel
        private let restoreState = PDFAnnotationRestoreState()
        private var cancellable: AnyCancellable?
        private var annotationObservers: [NSObjectProtocol] = []
        private var isApplyingRestore = false
        
        init(_ parent: PDFAuxiliaryViewRepresentable, viewModel: DocumentViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                self.cancellable = viewModel.$documentUserInput.sink { [weak self] newValue in
                    self?.loadUserInput(documentUserInput: newValue)
                }
                self.startObservingAnnotationChanges()
            }
        }

        func loadUserInput(documentUserInput: [AnyUserInput]) {
            let candidates = restoreState.candidates(
                from: documentUserInput,
                matchingPDFIds: Set(parent.pdfs.map(\.id))
            )

            for candidate in candidates {
                guard let target = restoreTarget(for: candidate.pdfId) else {
                    continue
                }

                do {
                    let replacement = try stageReplacement(for: candidate, in: target.document)
                    try replaceAnnotations(in: target.document, with: replacement)
                    restoreState.recordRestoredSnapshot(candidate)
                } catch {
                    // Keep the displayed and last-known-good annotations intact.
                    print("Ignoring invalid PDF annotation snapshot for \(candidate.pdfId): \(error)")
                }
            }
        }

        private func restoreTarget(for pdfId: String) -> (document: Document, index: Int)? {
            guard let documents = tabbedPDFController?.documents else {
                return nil
            }

            let matchingIndices = parent.pdfs.indices.filter { parent.pdfs[$0].id == pdfId }
            guard matchingIndices.count == 1,
                  let index = matchingIndices.first,
                  documents.indices.contains(index) else {
                return nil
            }

            return (documents[index], index)
        }

        private func stageReplacement(
            for snapshot: UserInputAnnotation,
            in document: Document
        ) throws -> [Annotation] {
            guard let documentProvider = document.documentProviders.first else {
                throw PDFAnnotationRestoreError.missingDocumentProvider
            }

            var replacement: [Annotation] = []
            var seenPageIndices: Set<Int> = []
            let pageCount = Int(document.pageCount)

            for pageSnapshot in snapshot.data {
                guard pageSnapshot.pageIndex >= 0,
                      pageCount == 0 || pageSnapshot.pageIndex < pageCount else {
                    throw PDFAnnotationRestoreError.invalidPageIndex
                }
                guard seenPageIndices.insert(pageSnapshot.pageIndex).inserted else {
                    throw PDFAnnotationRestoreError.duplicatePageIndex
                }

                for serializedAnnotation in pageSnapshot.annotations {
                    guard let annotationData = serializedAnnotation.data(using: .utf8) else {
                        throw PDFAnnotationRestoreError.invalidAnnotationEncoding
                    }

                    let decodedAnnotation = try Annotation(
                        fromInstantJSON: annotationData,
                        documentProvider: documentProvider
                    )
                    guard Int(decodedAnnotation.pageIndex) == pageSnapshot.pageIndex else {
                        throw PDFAnnotationRestoreError.mismatchedPageIndex
                    }

                    replacement.append(decodedAnnotation)
                }
            }

            return replacement
        }

        private func replaceAnnotations(
            in document: Document,
            with replacement: [Annotation]
        ) throws {
            // Instant JSON parsing above is deliberately side-effect free. Keep the
            // remove/add window as small as the SDK permits and suppress our dirty guard.
            isApplyingRestore = true
            defer { isApplyingRestore = false }

            let currentAnnotations = document.allAnnotations(of: .all).values.flatMap { $0 }
            if !currentAnnotations.isEmpty {
                guard document.remove(annotations: currentAnnotations, options: .none) else {
                    guard restoreOriginalAnnotations(currentAnnotations, in: document) else {
                        throw PDFAnnotationRestoreError.rollbackFailed
                    }
                    throw PDFAnnotationRestoreError.annotationRemovalFailed
                }
            }
            if !replacement.isEmpty {
                guard document.add(annotations: replacement, options: nil) else {
                    let removedPartialReplacement = removeAttachedAnnotations(
                        from: replacement,
                        in: document
                    )
                    let restoredOriginal = restoreOriginalAnnotations(
                        currentAnnotations,
                        in: document
                    )
                    guard removedPartialReplacement, restoredOriginal else {
                        throw PDFAnnotationRestoreError.rollbackFailed
                    }
                    throw PDFAnnotationRestoreError.annotationAdditionFailed
                }
            }
        }

        private func restoreOriginalAnnotations(
            _ originalAnnotations: [Annotation],
            in document: Document
        ) -> Bool {
            let attachedAnnotationIds = Set(
                document.allAnnotations(of: .all).values
                    .flatMap { $0 }
                    .map { ObjectIdentifier($0) }
            )
            let missingAnnotations = originalAnnotations.filter {
                !attachedAnnotationIds.contains(ObjectIdentifier($0))
            }

            return missingAnnotations.isEmpty ||
                document.add(annotations: missingAnnotations, options: nil)
        }

        private func removeAttachedAnnotations(
            from candidateAnnotations: [Annotation],
            in document: Document
        ) -> Bool {
            let candidateIds = Set(candidateAnnotations.map { ObjectIdentifier($0) })
            let attachedCandidates = document.allAnnotations(of: .all).values
                .flatMap { $0 }
                .filter { candidateIds.contains(ObjectIdentifier($0)) }

            return attachedCandidates.isEmpty ||
                document.remove(annotations: attachedCandidates, options: .none)
        }

        func saveUserInput(for documentToBeSaved: Document) {
            guard let documentId = viewModel.document?.id,
                  let documents = tabbedPDFController?.documents,
                  let index = documents.firstIndex(where: { $0 == documentToBeSaved }),
                  parent.pdfs.indices.contains(index),
                  let snapshot = makeUserInputSnapshot(
                    for: documentToBeSaved,
                    pdfId: parent.pdfs[index].id
                  ) else {
                return
            }

            // Record the exact in-memory snapshot before @Published emits it back to
            // this coordinator, avoiding a destructive self-restore during autosave.
            restoreState.recordLocalSnapshot(snapshot)
            viewModel.saveBlockUserInput(
                documentId: documentId,
                blockId: snapshot.blockId,
                userInputType: .annotation,
                userInput: AnyUserInput(snapshot)
            )
        }

        private func makeUserInputSnapshot(
            for document: Document,
            pdfId: String
        ) -> UserInputAnnotation? {
            let annotationsByPage = document.allAnnotations(of: .all)
            var pageSnapshots: [PDFAuxAnnotations] = []

            for pageIndex in annotationsByPage.keys.sorted(by: { $0.intValue < $1.intValue }) {
                guard let annotations = annotationsByPage[pageIndex] else {
                    continue
                }

                var serializedAnnotations: [String] = []
                for annotation in annotations {
                    do {
                        let data = try annotation.generateInstantJSON(version: .v1)
                        guard let serializedAnnotation = String(data: data, encoding: .utf8) else {
                            print("Unable to encode PDF annotation snapshot for \(pdfId)")
                            return nil
                        }
                        serializedAnnotations.append(serializedAnnotation)
                    } catch {
                        print("Unable to serialize PDF annotation snapshot for \(pdfId): \(error)")
                        return nil
                    }
                }

                pageSnapshots.append(PDFAuxAnnotations(
                    pageIndex: Int(pageIndex.intValue),
                    annotations: serializedAnnotations
                ))
            }

            return UserInputAnnotation(
                pdfId: pdfId,
                data: pageSnapshots,
                inputType: .annotation,
                blockId: pdfId,
                timestamp: Int(Date().timeIntervalSince1970)
            )
        }

        private func startObservingAnnotationChanges() {
            guard annotationObservers.isEmpty else { return }

            let names: [NSNotification.Name] = [
                .PSPDFAnnotationsAdded,
                .PSPDFAnnotationsRemoved,
                .PSPDFAnnotationChanged
            ]
            annotationObservers = names.map { name in
                NotificationCenter.default.addObserver(
                    forName: name,
                    object: nil,
                    queue: .main
                ) { [weak self] notification in
                    self?.annotationDidChange(notification)
                }
            }
        }

        private func annotationDidChange(_ notification: Notification) {
            guard !isApplyingRestore else { return }

            let annotations: [Annotation]
            if let changedAnnotation = notification.object as? Annotation {
                annotations = [changedAnnotation]
            } else if let changedAnnotations = notification.object as? NSArray {
                annotations = changedAnnotations.compactMap { $0 as? Annotation }
            } else {
                return
            }

            for annotation in annotations {
                if let pdfId = pdfId(for: annotation) {
                    restoreState.markDirty(pdfId: pdfId)
                }
            }
        }

        private func pdfId(for annotation: Annotation) -> String? {
            guard let documents = tabbedPDFController?.documents else {
                return nil
            }
            let documentProvider = annotation.documentProvider

            for (index, document) in documents.enumerated()
                where parent.pdfs.indices.contains(index) {
                if document.documentProviders.contains(where: { $0 === documentProvider }) {
                    return parent.pdfs[index].id
                }
            }

            return nil
        }
        
        func pdfViewController(_ pdfController: PDFViewController, didFinishRenderTaskFor: PDFPageView) {
            fixTabBar()
        }
        
        func pdfViewController(_ pdfController: PDFViewController, didExecute: Action) {
            fixTabBar()
        }
        
        func pdfViewController(_ pdfController: PDFViewController, didShowUserInterface: Bool) {
            fixTabBar()
        }

        func pdfViewController(_ pdfController:PDFViewController, didCleanupPageView: PDFPageView, forPageAt: Int) {
            fixTabBar()
        }
        
        func pdfViewController(_ pdfController:PDFViewController, didConfigurePageView: PDFPageView, forPageAt: Int) {
            fixTabBar()
        }
        
        func pdfViewController(_ pdfController: PDFViewController, didChange: Document?) {
            fixTabBar()
        }
        
        func fixTabBar () {
            if let t = tabbedPDFController {
                t.tabbedBar.frame.origin = CGPoint(x: 0, y: parent.viewType == .segment ? parent.getNavbarMaxY() : 0)
            }
        }
        
        deinit {
            cancellable?.cancel()
            annotationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        }
    }
}

struct PDFAuxiliaryView: View {
    var pdfs: [PDFAux]
    var viewType: PDFAxiliryViewType = .aux
    @State var showNavigationBarButtons: Bool = true

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var pdfTabbedViewController: PDFAuxiliaryTabbedViewController?
    
    var btnBack: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
           Image(systemName: "arrow.backward")
               .renderingMode(.original)
               .foregroundColor(.black | .white)
               .aspectRatio(contentMode: .fit)
        }
    }
    
    var body: some View {
        PDFAuxiliaryViewRepresentable(
            pdfs: pdfs,
            viewType: viewType,
            showNavigationBarButtons: showNavigationBarButtons,
            pdfTabbedViewController: $pdfTabbedViewController
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    (pdfTabbedViewController?.pdfController as? PDFAuxiliaryViewController)?.toggleAnnotations()
                }) {
                    Image(systemName: "pencil.tip.crop.circle").imageScale(.medium)
                }
            }
            
            ToolbarItem {
                Button(action: {
                    (pdfTabbedViewController?.pdfController as? PDFAuxiliaryViewController)?.toggleOutline()
                }) {
                    Image(systemName: "bookmark").imageScale(.medium)
                }
            }
            
            ToolbarItem {
                Button(action: {
                    (pdfTabbedViewController?.pdfController as? PDFAuxiliaryViewController)?.toggleSettings()
                }) {
                    Image(systemName: "gearshape").imageScale(.medium)
                }
            }
        }
    }
}
