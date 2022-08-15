//
//  TabBarViewController.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 14/08/22.
//  Copyright © 2022 Adventech. All rights reserved.
//

import AsyncDisplayKit

enum TabBarItem {
    case sabbathSchool
    case devotional
    case personalMinistries

    static func defaultItems() -> [TabBarItem] {
        return [.sabbathSchool, .devotional, .personalMinistries]
    }
}

class TabBarViewController: ASTabBarController {
    
    let sabbathSchool = QuarterlyWireFrame.createQuarterlyModule(initiateOpen: false)
    let devotional = DevotionalWireFrame.createDevotionalModuleNav()
    let personalMinistries = PersonalMinistriesWireFrame.createPersonalMinistriesModuleNav()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var viewControllers: [UIViewController]? {
        didSet { setupItems() }
    }
    
    func setupItems() {
        var items = [TabBarItem]()
        viewControllers?.forEach({ item in
            switch item {
            case sabbathSchool:
                items.append(.sabbathSchool)
            case devotional:
                items.append(.devotional)
            case personalMinistries:
                items.append(.personalMinistries)
            default:
                break
            }
        })
    }
    
    func tabBarControllersFor(items: [TabBarItem]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        items.forEach({ item in
            switch item {
            case .sabbathSchool:
                viewControllers.append(sabbathSchool)
            case .devotional:
                devotional.tabBarItem.title = "Devotional".localized()
                viewControllers.append(devotional)
            case .personalMinistries:
                personalMinistries.tabBarItem.title = "Personal Ministries".localized()
                viewControllers.append(personalMinistries)
            }
        })
        return viewControllers
    }

}
