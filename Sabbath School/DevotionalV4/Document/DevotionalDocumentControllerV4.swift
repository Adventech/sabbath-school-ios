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
import SwiftEntryKit
import AsyncDisplayKit

class DevotionalDocumentControllerV4: CompositeScrollViewController {

    private var document: SSPMDocument?
    private let devotionalInteractor = DevotionalInteractor()
    private let devotionalPresenter = DevotionalPresenter()
    private let index: String
    private var yPosition: CGFloat = 0
    
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
        
        setupMainView()
        bindUI()
        
        self.devotionalInteractor.retrieveDocument(index: index) { resourceDocument in
            self.document = resourceDocument
            
            self.hosting.rootView.viewModel.document = self.document
            for (index, block) in (self.document?.blocks ?? []).enumerated() {
                self.hosting.rootView.viewModel.blocks.append(BlockViewModel(id: index, block: block))
            }
        }
    }
    
    private func bindUI() {
        self.hosting.rootView.didTapLink = { bibleVerses, link in
            self.didClickBible(bibleVerses: bibleVerses, verse: link)
        }
        
        self.hosting.rootView.didClickReference = { scope, index in
            self.didClickReference(scope: scope, index: index)
        }
        
        self.hosting.rootView.didScroll = { yPosition in
            self.yPosition = yPosition
            self.scrollBehavior()
        }
    }
    
    override var tintColors: (fromColor: UIColor, toColor: UIColor) {
        return (AppStyle.Base.Color.navigationTint, AppStyle.Base.Color.navigationTint)
    }
    
    override var navbarTitle: String {
        return self.document?.title ?? ""
    }
    
    override var touchpointRect: CGRect? {
        return CGRect(x: 0, y: yPosition, width: 0 ,height: 0)
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
}

// MARK: Navigation

private extension DevotionalDocumentControllerV4 {
    func didClickBible(bibleVerses: [BibleVerses], verse: String) {
        let bibleScreen = BibleWireFrame.createBibleModule(bibleVerses: bibleVerses, verse: verse)
        let navigation = ASNavigationController(rootViewController: bibleScreen)
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        SwiftEntryKit.display(entry: navigation, using: Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: Preferences.currentTheme().backgroundColor))
    }
    
    func didClickReference(scope: Block.ReferenceScope, index: String) {
        switch scope {
        case .document:
            self.devotionalPresenter.presentDevotionalDocument(source: self, index: index)
        case .resource:
            self.devotionalPresenter.presentDevotionalDetail(source: self, index: index)
        }
    }
}
