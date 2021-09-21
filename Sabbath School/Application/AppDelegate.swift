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
import AuthenticationServices
import FBSDKCoreKit
import Firebase
import FirebaseMessaging
import GoogleSignIn
import UIKit
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Configuration.configureArmchair()
        Configuration.configureFirebase()
        Configuration.configureFontblaster()
        Configuration.configurePreferences()
        Configuration.configureNotifications(application: application)
        Configuration.configureAuthentication()
        Configuration.configurePDF()
        Configuration.configureMisc()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.path.range(of: Constants.URLs.webLinkRegex, options: .regularExpression) != nil {
            return handleAppLink(url: url)
        }
        
        let facebookHandle = ApplicationDelegate.shared.application(application,
                                                                    open: url,
                                                                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                                    annotation: options[UIApplication.OpenURLOptionsKey.annotation])

        if facebookHandle {
            return facebookHandle
        }
        
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        // if let messageID = userInfo[Constants.DefaultKey.gcmMessageIDKey] {
        //     print("Message ID: \(messageID)")
        // }

        // Print full message.
        // print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        // if let messageID = userInfo[Constants.DefaultKey.gcmMessageIDKey] {
        //     print("Message ID: \(messageID)")
        // }
        // Print full message.
        // print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == Constants.DefaultKey.shortcutItem {
            guard let quarterlyIndex = shortcutItem.userInfo?["index"] as? String else { return }
            launchQuarterly(quarterlyIndex: quarterlyIndex, initiateOpen: true)
            
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            guard let url = userActivity.webpageURL else { return false }
            if url.path.range(of: Constants.URLs.webLinkRegex, options: .regularExpression) != nil {
                return handleAppLink(url: url)
            }
            return true
        }
        
        if userActivity.activityType == CSSearchableItemActionType {
            guard let quarterlyIndex = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return false }
            launchQuarterly(quarterlyIndex: quarterlyIndex)
        }

        return true
    }
    
    func handleAppLink(url: URL) -> Bool {
        guard url.pathComponents.count > 1 else { return true }
        
        let languageCode: String? = url.pathComponents.count >= 2 ? url.pathComponents[1] : nil
        let quarterlyIndex: String? = url.pathComponents.count >= 3 ? String(format: "%@-%@", languageCode!, url.pathComponents[2]) : nil
        let lessonIndex: String? = url.pathComponents.count >= 4 ? String(format: "%@-%@", quarterlyIndex!, url.pathComponents[3]) : nil
        let readIndex: Int? = url.pathComponents.count == 5 ? Int(url.pathComponents[4].prefix(2))!-1 : nil
        
        if let languageCode = languageCode {
            do {
                let dictionary = try JSONEncoder().encode(QuarterlyLanguage(code: languageCode, name: Locale.current.localizedString(forLanguageCode: languageCode) ?? languageCode))
                Preferences.userDefaults.set(dictionary, forKey: Constants.DefaultKey.quarterlyLanguage)
            } catch {
                return true
            }
        }
        
        if let readIndex = readIndex {
            launchLesson(quarterlyIndex: quarterlyIndex!, lessonIndex: lessonIndex!, readIndex: readIndex)
            return true
        }
        
        if let lessonIndex = lessonIndex {
            launchLesson(quarterlyIndex: quarterlyIndex!, lessonIndex: lessonIndex)
            return true
        }
        
        if let quarterlyIndex = quarterlyIndex {
            launchQuarterly(quarterlyIndex: quarterlyIndex)
            return true
        }
        
        if languageCode != nil {
            launchQuarterlies()
            return true
        }
        
        return true
    }
    
    func launchQuarterlies() {
        let quarterlyController = QuarterlyWireFrame.createQuarterlyModule()
        Configuration.window?.rootViewController = quarterlyController
        Configuration.window?.makeKeyAndVisible()
    }
    
    func launchQuarterly(quarterlyIndex: String, initiateOpen: Bool = false) {
        let quarterlyController = QuarterlyWireFrame.createQuarterlyModule()
        let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: initiateOpen)
        quarterlyController.pushViewController(lessonController, animated: false)
        Configuration.window?.rootViewController = quarterlyController
        Configuration.window?.makeKeyAndVisible()
    }
    
    func launchLesson(quarterlyIndex: String, lessonIndex: String, readIndex: Int? = nil, initiateOpen: Bool = false) {
        let quarterlyController = QuarterlyWireFrame.createQuarterlyModule()
        let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: initiateOpen)
        let readController = ReadWireFrame.createReadModule(lessonIndex: lessonIndex, readIndex: readIndex)
        quarterlyController.pushViewController(lessonController, animated: false)
        quarterlyController.pushViewController(readController, animated: false)
        Configuration.window?.rootViewController = quarterlyController
        Configuration.window?.makeKeyAndVisible()
    }
}
