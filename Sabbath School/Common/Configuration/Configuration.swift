/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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
import Alamofire
import AsyncDisplayKit
import AuthenticationServices
import FontBlaster
import GoogleSignIn
import UIKit
import StoreKit
import WidgetKit
import PSPDFKit

class Configuration: NSObject {
    static var window: UIWindow?
    
    static func configurePDF() {
        SDK.setLicenseKey("ZLQj7zvL9bCaR1f8ZJimIEuUhCGSJ6H4aCl4nRLStyNmHQS/IShh/DySMqXHBVCg9vNn7+arORfAt8EQocSX9Hx6iJ8lFyovEBf7vA06qbEksaVHAk6djHfj6R6TCkG0LDLA0pQxbgTjHCgOYbKf2bTi+mpwf2g0qu+lL9DyBFt3uPRTbl5l9a/vFfm9uX7UchjpkLBcrmKCsWqTU4CYrM0JQZrNx+7t4dF2DUr1SdRaybR0QaWzOPMJiUFLpW/eA8PdLnGLdvnpvqXMigqC9k2RPAs1WL4fPxP4ttgs0ZX/cjqxI+VOhwNzP2RNzhYGPxH/J1/tAQGX+mxSNp8rmffSopvDtQL6r1REYlF61/y0tYV3z66R9n4gESGQTJimtPntMdB8psbSBfadY1+CKLpWVWMEeOKk0lHbiBWx2s17ryAPWhugWDUCyIcrPpHioQT+j/4ff+HRNgYi/9iMThbhdLxsD93UbnWLYuO7+8fPayi9ptNqWrnA6nzoNXncfVp0KMiabWMwOv61Qrgos5I+qr7ceWUIqC6kDB5bjInPWFKNrGuVxB0Ipiv0ZhLuw/eyrx5TILuqNDBGLgI2W7Q8sYHOhmcaRHRpDkyr4OY=",
                          options: [.fileCoordinationEnabled: false])
        
        SDK.shared.imageLoadingHandler = { imageName in
            if imageName == "edit_annotations" {
                return R.image.iconPdfAnnotations()
            }
            
            if imageName == "outline" {
                return R.image.iconPdfBookmarks()
            }
            
            if imageName == "settings" {
                return R.image.iconNavbarSettings()
            }
            
            return nil
        }
    }
    
    static func configureMisc() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        AudioPlayback.configure()
    }
    
    static func configureAuthentication() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.layer.cornerRadius = 6
        window?.clipsToBounds = true
        window?.tintColor = AppStyle.Base.Color.navigationTint
        
        if #available(iOS 13, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.appleIDStateDidRevoked(_:)), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
        
        // Check if Sign-in With Apple is still valid
        if #available(iOS 13, *) {
            if let userID = Preferences.userDefaults.string(forKey: Constants.DefaultKey.appleAuthorizedUserIdKey) {
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
        
        if (PreferencesShared.loggedIn()) {
            window?.rootViewController = QuarterlyWireFrame.createQuarterlyModule(initiateOpen: true)
        } else {
            window?.rootViewController = LoginWireFrame.createLoginModule()
        }
        
        window?.makeKeyAndVisible()
    }
    
    static func configureArmchair() {
        Armchair.appID("895272167")
        Armchair.shouldPromptClosure { info -> Bool in
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                return false
            } else {
                return true
            }
        }
    }
    
    static func configureCache() {
        ConfigurationShared.configureCache()
    }
    
    static func configureFontblaster() {
        FontBlaster.blast()
    }
    
    static func configurePreferences() {
        Preferences.migrateUserDefaultsToAppGroups()
        
        Preferences.userDefaults.register(defaults: [
            Constants.DefaultKey.tintColor: UIColor.baseBlue.hex(),
            Constants.DefaultKey.settingsReminderStatus: true,
            Constants.DefaultKey.settingsDefaultReminderTime: Constants.DefaultKey.settingsReminderTime
        ])

        if Helper.firstRun() {
            Preferences.userDefaults.set(false, forKey: Constants.DefaultKey.firstRun)
            Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.migrationToAppGroups)
            SettingsController.setUpLocalNotification()
        }
    }
    
    static func configureNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    static func reloadAllWidgets() {
        if #available(iOS 14.0, *) {
            #if arch(arm64) || arch(i386) || arch(x86_64)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
    
    @objc func appleIDStateDidRevoked(_ notification: Notification) {
        if PreferencesShared.loggedIn() {
            SettingsController.logOut()
        }
    }
}
