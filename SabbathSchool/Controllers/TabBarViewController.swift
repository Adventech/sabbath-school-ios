//
//  TabBarViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 05/01/17.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

enum TabBarItem {
    case lesson
    case notes
    case profile
    
    static func defaultItems() -> [TabBarItem] {
        return [.lesson, .notes, .profile]
    }
}

final class TabBarViewController: ASTabBarController {
    override var viewControllers: [UIViewController]? {
        didSet { setupItems() }
    }
    
    var tabBarItems = [TabBarItem]()
    var previousViewController: UIViewController?
    
    let lesson = ASNavigationController(rootViewController: QuarterliesViewController())
    let profile = ASNavigationController(rootViewController: ProfileViewController())
    let notes = ASNavigationController(rootViewController: NotesViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        // Colorize unselected image
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageTintColor(UIColor.init(hex: "#848484"))
            }
        }
        
        // Title position
        for item in tabBar.items! {
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 15)
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
    
    // MARK: Match current ViewControllers
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        setupItems()
    }
    
    func setupItems() {
        var items = [TabBarItem]()
        viewControllers?.forEach({ (item) in
            switch item {
            case lesson:
                items.append(.lesson)
            case notes:
                items.append(.notes)
            case profile:
                items.append(.profile)
            default:
                break
            }
        })
        tabBarItems = items
    }
    
    func tabBarControllersFor(items: [TabBarItem]) -> [UIViewController] {
        var viewControllers = [UIViewController]()
//        lesson.tabBarItem.title = NSLocalizedString("Lesson", comment: "")
        
        items.forEach { (item) in
            switch item {
            case .lesson:
                viewControllers.append(lesson)
            case .notes:
                viewControllers.append(notes)
            case .profile:
                viewControllers.append(profile)
            }
        }
        return viewControllers
    }
    
    // MARK: Orientation
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard previousViewController == viewController else {
            previousViewController = viewController
            return
        }
        
        switch viewController {
        case lesson:
            if let lesson = lesson.viewControllers.last as? QuarterliesViewController {
                lesson.tableNode.view.setContentOffset(CGPoint.zero, animated: true)
            }
        default:
            break
        }
        
        previousViewController = viewController
    }
}
