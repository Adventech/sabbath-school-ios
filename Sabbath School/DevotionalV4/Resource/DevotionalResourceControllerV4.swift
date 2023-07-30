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

final class DevotionalResourceControllerV4: CompositeScrollViewController {
    
    private let devotionalInteractor = DevotionalInteractor()
    private var devotionalResource: Resource?
    private let resourceIndex: String
    private let presenter = DevotionalPresenter()
    private var sectionStatus: Array<Bool> = []
    private var yPosition: CGFloat = 0
    
    let hosting = UIHostingController(rootView: DevotionalResource())
    
    // MARK: Inits
    
    init(resourceIndex: String) {
        self.resourceIndex = resourceIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setBackButton()
        setupMainView()
        bindUI()
        
        self.devotionalInteractor.retrieveResource(index: resourceIndex) { resource in
            self.devotionalResource = resource
            self.sectionStatus = Array(repeating: self.devotionalResource?.kind == .devotional ? false : true, count: self.devotionalResource?.sections?.count ?? 0)

            self.hosting.rootView.viewModel.resource = resource
            
            for section in (resource.sections ?? []).enumerated() {
                let element = SSPMSectionViewModel(id: section.offset, title: section.element.title, documents: section.element.documents)
                self.hosting.rootView.viewModel.sections.append(element)
            }
        }
    }
    
    private func bindUI() {
        self.hosting.rootView.didTapDocument = { index in
            self.presenter.presentDevotionalDocument(source: self, index: index)
        }
        
        self.hosting.rootView.didScroll = { yPosition in
            self.yPosition = yPosition
            self.scrollBehavior()
        }
    }
    
    override var navbarTitle: String {
        return self.devotionalResource?.title ?? ""
    }
    
    override var touchpointRect: CGRect? {
        return CGRect(x: 0, y: yPosition, width: 0 ,height: 0)
    }
}

// MARK: Setup UI

private extension DevotionalResourceControllerV4 {
    
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

