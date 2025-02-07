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

struct PDFAuxiliaryViewRepresentable: UIViewControllerRepresentable, PDFAuxiliaryViewControllerDelegate {
    var pdfs: [PDFAux]
    var viewType: PDFAxiliryViewType = .aux
    var showNavigationBarButtons: Bool = true
    
    @State var tabbedPDFController: PDFAuxiliaryTabbedViewController? = nil
    
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
        
        pdfController.pdfAuxiliaryViewControllerDelegate = self
        pdfController.viewType = viewType
        pdfController.showNavigationBarButtons = showNavigationBarButtons
        
        if viewType == .segment {
            pdfController.delegate = context.coordinator
        }

        let tabbedPDFController = PDFAuxiliaryTabbedViewController(pdfViewController: pdfController)
        tabbedPDFController.documents = documents
        
        DispatchQueue.main.async {
            self.tabbedPDFController = tabbedPDFController
            self.pdfTabbedViewController = tabbedPDFController
            self.loadUserInput(documentUserInput: viewModel.documentUserInput)            
        }
        
        return tabbedPDFController
    }
    
    func loadUserInput(documentUserInput: [AnyUserInput]) {
        let userInput = documentUserInput.filter { $0.inputType == .annotation }
        
        if let documents = self.tabbedPDFController?.documents {
            documents.forEach { document in
                let allAnnotations = document.allAnnotations(of: .all)

                for pageIndex in allAnnotations {
                    document.remove(annotations: pageIndex.value, options: .none)
                }
            }
        }
        
        userInput.forEach { userInput in
            if let annotation = userInput.asType(UserInputAnnotation.self),
               let pdfIndex = pdfs.firstIndex(where: { $0.id == annotation.pdfId }),
               let document = self.tabbedPDFController?.documents[pdfIndex]
            {
                for pageAnnotations in annotation.data {

                    guard let documentProvider = document.documentProviders.first else { continue }
                    var annotations: [Annotation] = []

                    for annotation in pageAnnotations.annotations {
                        do {
                            let annotation = try Annotation(fromInstantJSON: annotation.data(using: .utf8)!, documentProvider: documentProvider)
                            annotations.append(annotation)
                        } catch let error as NSError {
                            print(error)
                        }

                    }
                    document.add(annotations: annotations)
                }
            }
        }
    }
    
    func saveUserInput(for documentToBeSaved: Document) {
        if let documents = self.tabbedPDFController?.documents {
            for (index, document) in documents.enumerated() {
                guard documentToBeSaved == document else { continue }
                
                let inkAnnotations = document.allAnnotations(of: .all)
                
                var allAnnotations: [PDFAuxAnnotations] = []
                for pageIndex in inkAnnotations {
                    var annotations: [String] = []
                    for annotation in pageIndex.value {
                        let data = try! annotation.generateInstantJSON(version: .v1)
                        let jsonString = String(data: data, encoding: .utf8)
                        annotations.append(jsonString!)
                    }
                    allAnnotations.append(PDFAuxAnnotations(pageIndex: Int(pageIndex.key.intValue), annotations: annotations))
                }
                
                self.viewModel.saveBlockUserInput(documentId: self.viewModel.document?.id, blockId: self.pdfs[index].id, userInputType: .annotation, userInput: AnyUserInput(UserInputAnnotation(pdfId: self.pdfs[index].id, data: allAnnotations, inputType: .annotation, blockId: self.pdfs[index].id)))
            }
        }
    }

    func updateUIViewController(_ uiViewController: PDFAuxiliaryTabbedViewController, context: Context) {
        uiViewController.tabbedBar.frame.origin = CGPoint(x: 0, y: 90)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    class Coordinator: NSObject, PDFViewControllerDelegate {
        var parent: PDFAuxiliaryViewRepresentable
        var viewModel: DocumentViewModel
        private var cancellable: AnyCancellable?
        
        init(_ parent: PDFAuxiliaryViewRepresentable, viewModel: DocumentViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()
            
            DispatchQueue.main.async { [self] in
                cancellable = viewModel.$documentUserInput.sink { newValue in
                    self.parent.loadUserInput(documentUserInput: newValue)
                }
            }
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
            if let t = parent.tabbedPDFController, parent.viewType == .segment {
                t.tabbedBar.frame.origin = CGPoint(x: 0, y: parent.getNavbarMaxY())
            }
        }
        
        deinit {
            cancellable?.cancel()
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
