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

class PDFReadViewController: PDFViewController {
    var vcDelegate: PDFReadControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        navigationItem.setRightBarButtonItems([], for: .document, animated: false)
        navigationItem.setRightBarButtonItems([settingsButtonItem, outlineButtonItem, annotationButtonItem], for: .document, animated: false)
        navigationItem.setRightBarButtonItems([thumbnailsButtonItem], for: .thumbnails, animated: false)
        
        // let bibleBarButtonItem = UIBarButtonItem(
        //     image: R.image.iconPdfBible(),
        //     style: .plain,
        //     target: self,
        //     action: #selector(showBible(sender:)))

        // navigationItem.rightBarButtonItems?.insert(bibleBarButtonItem, at: 1)
        documentInfoCoordinator.availableControllerOptions = [.outline, .bookmarks, .annotations]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.barTintColor = AppStyle.Base.Color.tableCellBackground
        self.navigationController?.navigationBar.tintColor = AppStyle.Base.Color.navigationTint
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let documentString = document?.documentIdString {
            vcDelegate?.uploadAnnotations(documentId: documentString)
        }
        
        Preferences.userDefaults.set(configuration.pageTransition.rawValue, forKey: Constants.DefaultKey.pdfConfigurationPageTransition)
        Preferences.userDefaults.set(configuration.pageMode.rawValue, forKey: Constants.DefaultKey.pdfConfigurationPageMode)
        Preferences.userDefaults.set(configuration.scrollDirection.rawValue, forKey: Constants.DefaultKey.pdfConfigurationScrollDirection)
        Preferences.userDefaults.set(configuration.spreadFitting.rawValue, forKey: Constants.DefaultKey.pdfConfigurationSpreadFitting)
    }
    
    override func documentViewControllerDidLoad() {
        super.documentViewControllerDidLoad()
        vcDelegate?.loadAnnotations()
    }
    
    override func handleAutosaveRequest(for document: Document, reason: PSPDFAutosaveReason) {
        super.handleAutosaveRequest(for: document, reason: reason)
        if let documentString = document.documentIdString {
            vcDelegate?.uploadAnnotations(documentId: documentString)
        }
        
    }
    
//    @objc func showBible(sender: UIBarButtonItem) {
//        UIApplication.shared
//            .sendAction(searchButtonItem.action!, to: searchButtonItem.target!,
//                        from: settingsButtonItem, for: nil)
//        vcDelegate?.didTapBible()
//    }
}
