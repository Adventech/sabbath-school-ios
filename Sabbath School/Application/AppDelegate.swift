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

import Armchair
import AsyncDisplayKit
import AuthenticationServices
import FacebookCore
import Firebase
import FirebaseDatabase
import UserNotifications
import FontBlaster
import GoogleSignIn
import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Armchair.appID("895272167")

        Armchair.shouldPromptClosure { info -> Bool in
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                return false
            } else {
                return true
            }
        }
        
        #if DEBUG
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-Stage", ofType: "plist")
        #else
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")
        #endif

        let fileopts = FirebaseOptions.init(contentsOfFile: filePath!)

        FirebaseApp.configure(options: fileopts!)
        Database.database().isPersistenceEnabled = true
        Messaging.messaging().delegate = self

        FontBlaster.blast()

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        if #available(iOS 13, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appleIDStateDidRevoked(_:)), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
            // NotificationCenter.default.removeObserver(self, name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }

        // Register initial defaults
        UserDefaults.standard.register(defaults: [
            Constants.DefaultKey.tintColor: UIColor.baseBlue.hex(),
            Constants.DefaultKey.settingsReminderStatus: true,
            Constants.DefaultKey.settingsDefaultReminderTime: Constants.DefaultKey.settingsReminderTime
        ])

        if firstRun() {
            UserDefaults.standard.set(false, forKey: Constants.DefaultKey.firstRun)
            SettingsController.setUpLocalNotification()
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.layer.cornerRadius = 6
        window?.clipsToBounds = true
        
        if #available(iOS 13, *) {
            if let userID = UserDefaults.standard.string(forKey: Constants.DefaultKey.appleAuthorizedUserIdKey) {
                ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID, completion: { []
                    credentialState, error in
                    
                    switch(credentialState) {
                    case .authorized:
                        break
                    case .notFound,
                         .transferred,
                         .revoked:
                        SettingsController.logOut(presentLoginScreen: false)
                        break
                    @unknown default:
                        break
                    }
                })
            }
        }

        if (Auth.auth().currentUser) != nil {
            window?.rootViewController = QuarterlyWireFrame.createQuarterlyModule()

            UIApplication.shared.shortcutItems = [
                .init(
                    type: Constants.openTodayLessonShortcutItemType,
                    localizedTitle: "Today's Lesson".localized(),
                    localizedSubtitle: nil,
                    icon: .init(templateImageName: "icon-lesson"),
                    userInfo: nil
                )
            ]
        } else {
            window?.rootViewController = LoginWireFrame.createLoginModule()
        }

        window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let facebookHandle = ApplicationDelegate.shared.application(application, open: url, options: options)

        if facebookHandle {
            return facebookHandle
        }

        return GIDSignIn.sharedInstance().handle(url)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[Constants.DefaultKey.gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[Constants.DefaultKey.gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")

        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if shortcutItem.type == Constants.openTodayLessonShortcutItemType {
            guard let navigationController = UIApplication.shared.delegate?.window??.rootViewController as? ASNavigationController else { return }
            
            var quarterlyController: QuarterlyController?
            
            for controller in navigationController.viewControllers {
                guard ((controller as? QuarterlyController) != nil) else { continue }
                
                quarterlyController = controller as? QuarterlyController
                break
            }
            
            guard quarterlyController != nil else { return }
            guard ((quarterlyController?.dataSource.first) != nil) else { return }
            quarterlyController?.showLessonScreen(quarterly: quarterlyController!.dataSource.first!)
        }
    }
    
    @objc func appleIDStateDidRevoked(_ notification: Notification) {
        if let providerId = Auth.auth().currentUser?.providerData.first?.providerID, providerId == "apple.com" {
            SettingsController.logOut()
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[Constants.DefaultKey.gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[Constants.DefaultKey.gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
}
