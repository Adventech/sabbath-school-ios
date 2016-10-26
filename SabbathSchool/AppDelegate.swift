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
import FacebookCore

typealias User = FIRUser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase SDK
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        // Google SDK
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Facebook SDK
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
    }
    
    // MARK: Open URL
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookHandle = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
        if facebookHandle {
            return facebookHandle
        }
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let facebookHandle = SDKApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        if facebookHandle {
            return facebookHandle
        }
        
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
    
    func finishLoginWith(credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.loginAnimated()
        }
    }
    
    func signInAnonymously() {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.loginAnimated()
        })
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
        finishLoginWith(credential: credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}
