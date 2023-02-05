//
//  SSNavigationController.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 05/02/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import AsyncDisplayKit

final class SSNavigationController: ASNavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        NotificationCenter.default.post(name: .hideTabBar, object: shouldHideTabbar(basedOn: viewController))
    }
}

// MARK: TabBar

private extension SSNavigationController {
    func shouldHideTabbar(basedOn viewController: UIViewController) -> Bool {
        return viewController is TabBarLessViewController
    }
}

