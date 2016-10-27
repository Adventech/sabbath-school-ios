//
//  SwipeViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 27/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SwipeViewController: EZSwipeController {

    override func setupView() {
        datasource = self
        navigationBarShouldNotExist = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
    }
    
    // MARK: - Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension SwipeViewController: EZSwipeControllerDataSource {
    
    func viewControllerData() -> [UIViewController] {
        let profile = ASNavigationController(rootViewController: ProfileViewController())
        let lesson = ASNavigationController(rootViewController: QuarterliesViewController())
        let notes = ASNavigationController(rootViewController: NotesViewController())
        
        return [profile, lesson, notes]
    }
    
    func changedToPageIndex(_ index: Int) {
        print("Page has changed to: \(index)")
    }
    
    func moveToEnd() {
        self.moveToPage(2, animated: true)
    }
    
    func indexOfStartingPage() -> Int {
        return 1
    }
}
