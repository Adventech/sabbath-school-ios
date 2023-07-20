/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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

import UIKit
import SwiftUI

class DevotionalDocumentControllerV4: UIViewController {

    private var document: SSPMDocument?
    private let devotionalInteractor = DevotionalInteractor()
    private let index: String
    
    let hosting = UIHostingController(rootView: DevotionalDocument())
    
    init(index: String) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        setupNavigationBar()
        setupMainView()
        
        self.devotionalInteractor.retrieveDocument(index: index) { resourceDocument in
            self.document = resourceDocument
            self.title = resourceDocument.title
            
            self.hosting.rootView.viewModel.document = self.document
            for (index, block) in (self.document?.blocks ?? []).enumerated() {
                self.hosting.rootView.viewModel.blocks.append(BlockViewModel(id: index, block: block))
            }
        }
    }
}


// MARK: Setup UI

private extension DevotionalDocumentControllerV4 {
    
    func setupMainView() {
        addChild(hosting)
        
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hosting.view)
        
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        setNavigationBarOpacity(alpha: 0)

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle]

        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: AppStyle.Base.Color.navigationTitle,
            .font: R.font.latoBlack(size: 36)!
        ]
    }
}


