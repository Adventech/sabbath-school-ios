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

import PSPDFKitUI

protocol PDFAuxiliaryViewControllerDelegate: AnyObject {
    func saveUserInput(for document: Document)
}

class PDFAuxiliaryViewController: PDFViewController {
    weak var pdfAuxiliaryViewControllerDelegate: PDFAuxiliaryViewControllerDelegate?
    var viewType: PDFAxiliryViewType = .aux
    var showNavigationBarButtons: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAnnotationToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureAnnotationToolbar()
    }
    
    @objc func toggleAnnotations () {
        UsernameHelper.ask(forDefaultAnnotationUsernameIfNeeded: pdfController, completionBlock: { _ in
            self.annotationToolbarController?.toggleToolbar(animated: false)
        })
    }
    
    @objc func toggleOutline () {
        UIApplication.shared.sendAction(outlineButtonItem.action!, to: outlineButtonItem.target, from: nil, for: nil)
    }
    
    @objc func toggleSettings () {
        UIApplication.shared.sendAction(settingsButtonItem.action!, to: settingsButtonItem.target, from: nil, for: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Preferences.userDefaults.set(configuration.pageTransition.rawValue, forKey: Constants.DefaultKey.pdfConfigurationPageTransition)
        Preferences.userDefaults.set(configuration.pageMode.rawValue, forKey: Constants.DefaultKey.pdfConfigurationPageMode)
        Preferences.userDefaults.set(configuration.scrollDirection.rawValue, forKey: Constants.DefaultKey.pdfConfigurationScrollDirection)
        Preferences.userDefaults.set(configuration.spreadFitting.rawValue, forKey: Constants.DefaultKey.pdfConfigurationSpreadFitting)
    }
    
    
    override func handleAutosaveRequest(for document: Document, reason: PSPDFAutosaveReason) {
        super.handleAutosaveRequest(for: document, reason: reason)
        pdfAuxiliaryViewControllerDelegate?.saveUserInput(for: document)
    }
    
    public func configureAnnotationToolbar () {
        documentInfoCoordinator.availableControllerOptions = [.outline, .bookmarks, .annotations]
        
        let configuration = AnnotationToolConfiguration(annotationGroups: [
            
            AnnotationToolConfiguration.ToolGroup(items: [
                AnnotationToolConfiguration.ToolItem(type: .highlight),
                AnnotationToolConfiguration.ToolItem(type: .squiggly),
                AnnotationToolConfiguration.ToolItem(type: .underline),
                AnnotationToolConfiguration.ToolItem(type: .strikeOut)
            ]),
            
            AnnotationToolConfiguration.ToolGroup(items: [
                AnnotationToolConfiguration.ToolItem(type: .note)
            ]),
            
            AnnotationToolConfiguration.ToolGroup(items: [
                AnnotationToolConfiguration.ToolItem(type: .freeText)
            ]),
                
            AnnotationToolConfiguration.ToolGroup(items: [
                AnnotationToolConfiguration.ToolItem(type: .ink, variant: .inkPen, configurationBlock: AnnotationToolConfiguration.ToolItem.inkConfigurationBlock()),
                AnnotationToolConfiguration.ToolItem(type: .ink, variant: .inkMagic)
            ]),
            
            AnnotationToolConfiguration.ToolGroup(items: [
                AnnotationToolConfiguration.ToolItem(type: .eraser)
            ])
        ])

        annotationToolbarController?.annotationToolbar.configurations = [configuration]
        
        annotationToolbarController?.updateHostView(UIApplication.shared.currentNavigationController()?.topViewController?.view, container: UIApplication.shared.currentNavigationController()?.topViewController, viewController: self)
    }
}
