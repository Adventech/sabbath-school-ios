/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

import PSPDFKitUI

class PDFReadTabbedViewController: PDFTabbedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeMode = .disabled
        self.view.autoresizingMask = [.flexibleWidth]
        self.allowDraggingTabsToExternalTabbedBar = false
        self.allowDroppingTabsFromExternalTabbedBar = false
        self.allowReorderingDocuments = true
        self.openDocumentActionInNewTab = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateBarButtonItems() {
        let controller = self.pdfController
        controller.navigationItem.setRightBarButtonItems([controller.outlineButtonItem], for: .document, animated: false)
    }
    
    func loadAnnotations(documentIndex: Int, annotations: [PDFAnnotations]) {
        guard (0 ..< documents.count).contains(documentIndex) else { return }

        let document = documents[documentIndex]
        let allAnnotations = document.allAnnotations(of: .all)
        
        for pageIndex in allAnnotations {
            document.remove(annotations: pageIndex.value, options: .none)
        }
        
        try? document.save()
        
        for pageAnnotations in annotations {
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
