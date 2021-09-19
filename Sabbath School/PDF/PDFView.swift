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

import AsyncDisplayKit
import PSPDFKitUI

class PDFView: ASDisplayNode {
    let pdfControllerView = ASDisplayNode()
//    let bibleView = ASTableNode()
//    let bibleView = ASDisplayNode()
    var downloader: Downloader?
    var pdfController: PDFReadViewController!
    var tabbedPDFController: PDFReadTabbedViewController!
    var readViewController: ReadController!
    var showBible: Bool = false
    var divider = ASDisplayNode()
    var pdfLoaded: Bool = false
    
    override init() {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        divider.backgroundColor = .baseGray1
        automaticallyManagesSubnodes = true
    }
    
    func loadPDF(pdfs: [PDF], vcDelegate: PDFReadControllerDelegate?) {
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
            document.annotationSaveMode = .embedded
            documents.append(document)
        }
        
        let pdfConfiguration = PDFConfiguration {
            $0.isPageLabelEnabled = false
            $0.documentLabelEnabled = .NO
            $0.allowWindowTitleChange = false
            $0.allowToolbarTitleChange = false
            $0.isPageGrabberEnabled = false
            $0.thumbnailBarMode = .none
            $0.shouldHideStatusBarWithUserInterface = true
            $0.userInterfaceViewMode = .automatic
            $0.settingsOptions = [.all]
            $0.useParentNavigationBar = true
            
            $0.pageTransition = Preferences.getPdfPageTransition()
            $0.pageMode = Preferences.getPdfPageMode()
            $0.scrollDirection = Preferences.getPdfScrollDirection()
            $0.spreadFitting = Preferences.getPdfSpreadFitting()
        }
        
        pdfController = PDFReadViewController(document: nil, configuration: pdfConfiguration)
        if let vcDelegate = vcDelegate {
            pdfController.vcDelegate = vcDelegate
        }
        pdfController.view.autoresizingMask = [.flexibleWidth]
        
        tabbedPDFController = PDFReadTabbedViewController(pdfViewController: pdfController)
        tabbedPDFController.documents = documents
        
        pdfControllerView.addSubnode(ASDisplayNode { self.tabbedPDFController.view })
        pdfLoaded = true
    }
    
    override func layout() {
        super.layout()
        if !pdfLoaded { return }
        tabbedPDFController.view.frame = pdfControllerView.view.bounds
        tabbedPDFController.pdfController.view.frame = pdfControllerView.view.bounds
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let mainSpecChildren: [ASLayoutElement] = [pdfControllerView] // divider, bibleView
        let direction: ASStackLayoutDirection = Helper.isPad && constrainedSize.max.width > 400 ? .horizontal : .vertical
        
        if showBible {
            pdfControllerView.style.flexBasis = direction == .horizontal ? ASDimensionMake("70%") : ASDimensionMake("60%")
            // bibleView.style.flexBasis = direction == .horizontal ? ASDimensionMake("30%") : ASDimensionMake("40%")
            // divider.style.width = ASDimensionMakeWithPoints(1)
        } else {
            pdfControllerView.style.flexBasis = ASDimensionMake("100%")
            // bibleView.style.flexBasis = ASDimensionMake("0%")
            // divider.style.width = ASDimensionMakeWithPoints(0)
        }
        
        let mainSpec = ASStackLayoutSpec(
            direction: direction,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: mainSpecChildren)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: mainSpec)
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.pdfControllerView.frame = context.finalFrame(for: self.pdfControllerView)
                self.tabbedPDFController.view.frame = context.finalFrame(for: self.pdfControllerView)
                self.tabbedPDFController.pdfController.view.frame = context.finalFrame(for: self.pdfControllerView)
                // self.bibleView.frame = context.finalFrame(for: self.bibleView)
                self.divider.frame = context.finalFrame(for: self.divider)
                self.layoutIfNeeded()
            },
            completion: { finished in
                context.completeTransition(finished)
            }
        )
    }
}
