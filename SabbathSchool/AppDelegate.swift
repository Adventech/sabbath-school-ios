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
import GoogleSignIn

typealias User = FIRUser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Init Firebase
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Root View
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        
        applyCustomAppearance()
        
        //
        if (FIRAuth.auth()?.currentUser) != nil {
            window?.rootViewController = ASNavigationController(rootViewController: QuarterliesViewController())
        } else {
            window?.rootViewController = LoginViewController()
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    //
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        var options: [String: AnyObject] = [
//            UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
//            UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject
//        ]
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // MARK: - App Custom Appearance
    
    func applyCustomAppearance() {
        window?.tintColor = UIColor.baseGreen
        
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor.baseGreen), for: UIBarMetrics.default)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: R.font.latoMedium(size: 15)!]
        
        UITabBar.appearance().barTintColor = UIColor.baseGrayToolbar
        UIBarButtonItem.appearance().tintColor = UIColor.white
    }
    
    // MARK: - Login Actions
    
    func loginAnimated() {
        let viewController = ASNavigationController(rootViewController: QuarterliesViewController())
        UIView.transition(with: self.window!,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { self.window?.rootViewController = viewController },
                          completion: nil)
    }
    
    func logoutAnimated() {
        try! FIRAuth.auth()!.signOut()
        
        UIView.transition(with: self.window!,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { self.window?.rootViewController = LoginViewController() },
                          completion: nil)
    }
}

// MARK: - GIDSignInDelegate

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.loginAnimated()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}
