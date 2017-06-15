/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
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

import AsyncDisplayKit
import Crashlytics
import Fabric
import FacebookCore
import Firebase
import FirebaseDatabase
import FontBlaster
import GoogleSignIn
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let fabricAPIKeyPath = Bundle.main.path(forResource: "Fabric", ofType: "apiKey")
        let fabricAPIKey = try? String(contentsOfFile: fabricAPIKeyPath!, encoding: String.Encoding.utf8)
        
        Fabric.with([Crashlytics.start(withAPIKey: fabricAPIKey ?? "")])
        
        // TODO: - Configure per envoronment (stage, prod)
        
        let filePath = Bundle.main.path(forResource: "GoogleService-Info-Stage", ofType: "plist")
        let fileopts = FirebaseOptions.init(contentsOfFile: filePath!)
        
        FirebaseApp.configure(options: fileopts!)
        Database.database().isPersistenceEnabled = true
        
        FontBlaster.blast() { (fonts) in
            print(fonts) // fonts is an array of Strings containing font names
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.layer.cornerRadius = 6
        window?.clipsToBounds = true
        
        if (Auth.auth().currentUser) != nil {
            window?.rootViewController = QuarterlyWireFrame.createQuarterlyModule()
        } else {
            window?.rootViewController = LoginWireFrame.createLoginModule()
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let facebookHandle = SDKApplicationDelegate.shared.application(application, open: url, options: options)
        
        if facebookHandle {
            return facebookHandle
        }
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let facebookHandle = SDKApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        if facebookHandle {
            return facebookHandle
        }
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}

