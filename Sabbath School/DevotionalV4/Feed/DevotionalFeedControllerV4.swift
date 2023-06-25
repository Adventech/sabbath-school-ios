//
//  DevotionalFeedControllerV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 24/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import UIKit
import SwiftUI

final class DevotionalFeedControllerV4: UIViewController {
    
    private let devotionalInteractor = DevotionalInteractor()
    private var devotionalResources: [ResourceFeed] = []
    private let devotionalType: DevotionalType
    
    let hosting = UIHostingController(rootView: DevotionalFeed())
    
    // MARK: Inits
    
    init(devotionalType: DevotionalType) {
        self.devotionalType = devotionalType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupMainView()
        
        self.devotionalInteractor.retrieveFeed(devotionalType: self.devotionalType, language: "en") { resourceFeed in
            self.devotionalResources = resourceFeed
            self.hosting.rootView.viewModel.items.removeAll()
            for i in self.devotionalResources.enumerated() {
                self.hosting.rootView.viewModel.items.append(ResourceViewModel(id: i.offset, resourceFeed: i.element))
            }
        }
    }
}

// MARK: Setup UI

private extension DevotionalFeedControllerV4 {
    
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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        setNavigationBarOpacity(alpha: 1)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle]
        
        navigationItem.title = devotionalType.getTitle()
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: AppStyle.Base.Color.navigationTitle,
            .font: R.font.latoBlack(size: 36)!
        ]
    }
}
