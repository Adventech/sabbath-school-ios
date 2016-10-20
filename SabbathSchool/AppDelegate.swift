//
//  AppDelegate.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        applyCustomAppearance()
        
        self.window?.rootViewController = ASNavigationController(rootViewController: QuarterViewController())
        self.window?.makeKeyAndVisible()
        
        // Init Firebase
        FIRApp.configure()
        
        return true
    }

    // MARK: - App Custom Appearance
    
    func applyCustomAppearance() {
        window?.tintColor = UIColor.baseBlue
        
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor.baseBlue), for: UIBarMetrics.default)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: R.font.latoMedium(size: 15)!]
        
        UITabBar.appearance().barTintColor = UIColor.baseGrayToolbar
        UIBarButtonItem.appearance().tintColor = UIColor.white
    }
}

