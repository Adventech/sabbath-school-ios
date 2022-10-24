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
import Cache
import simd

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
    
    static func migrateUserAccountFromFirebase() {
        if (PreferencesShared.loggedIn() || Preferences.firebaseUserMigrated()) { return }
        
        let query: [String: AnyObject] = [
            kSecAttrService as String: Constants.API.LEGACY_API_KEY as AnyObject,
            kSecAttrAccessGroup as String: Constants.DefaultKey.appGroupName as AnyObject,
            kSecAttrAccount as String: "firebase_auth_firebase_user" as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

        guard status != errSecItemNotFound else { return }
        guard status == errSecSuccess else { return }
        guard let firebaseUserObject = itemCopy as? Data else { return }
        
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: firebaseUserObject)
            
            unarchiver.decodingFailurePolicy = .setErrorAndReturn
            unarchiver.setClass(FIRUser.self, forClassName: "FIRUser")
            unarchiver.setClass(FIRUserTokenService.self, forClassName: "FIRSecureTokenService")
            
            if let user: FIRUser = try? unarchiver.decodeTopLevelObject(of: FIRUser.self, forKey: "firebase_auth_stored_user_coder_key") {
                if !user.apiKey.isEmpty,
                   !user.uid.isEmpty,
                   let accessToken = user.tokenService?.accessToken,
                   let refreshToken = user.tokenService?.refreshToken
                {
                    let accountToken: AccountToken = AccountToken(apiKey: user.apiKey, refreshToken: refreshToken, accessToken: accessToken, expirationTime: 0)
                    let account: Account = Account(uid: user.uid, displayName: user.displayName, email: user.email, stsTokenManager: accountToken, isAnonymous: false)
                    let dictionary = try! JSONEncoder().encode(account)
                    
                    Preferences.userDefaults.set(dictionary, forKey: Constants.DefaultKey.accountObject)
                    Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.accountFirebaseMigrated)
                }
            }
        } catch {}
    }
    
    static func configureAuthentication() {
        self.migrateUserAccountFromFirebase()
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
        
        self.makeKeyAndVisible()
    }
    
    static func makeKeyAndVisible() {
        if (PreferencesShared.loggedIn()) {
            window?.rootViewController = getRootViewController()
        } else {
            window?.rootViewController = LoginWireFrame.createLoginModule()
        }
        
        window?.makeKeyAndVisible()
    }
    
    static func loginAnimated(_ completion: (() -> Void)? = nil) {
        UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.window?.rootViewController = self.getRootViewController()
        }, completion: { _ in
            completion?()
        })
    }
    
    public static func getRootViewController(quarterlyIndex: String? = nil,
                                              lessonIndex: String? = nil,
                                              readIndex: Int? = nil,
                                              initiateOpen: Bool = false) -> UIViewController {
        self.configureCache()
        var ret: UIViewController = QuarterlyWireFrame.createQuarterlyModule()
        
        let currentLanguage = PreferencesShared.currentLanguage()
        let devotionalInteractor = DevotionalInteractor()
        
        if let resourceInfo = devotionalInteractor.getDevotionalResourceInfo(key: devotionalInteractor.devotionalInfoEndpoint) {
            let resourceInfoForLanguage = resourceInfo.filter { $0.code == currentLanguage.code }
            if !resourceInfoForLanguage.isEmpty {
                let tabBarController = TabBarViewController()
                tabBarController.viewControllers = tabBarController.tabBarControllersFor(
                    pm: resourceInfoForLanguage.first?.pm ?? false,
                    study: resourceInfoForLanguage.first?.study ?? false,
                    quarterlyIndex: quarterlyIndex,
                    lessonIndex: lessonIndex,
                    readIndex: readIndex,
                    initiateOpen: initiateOpen)
                ret = tabBarController
            }
        }
        
        devotionalInteractor.retrieveResourceInfo()
        
        return ret
    }
    
    static func configureArmchair() {
        Armchair.appID("895272167")
        Armchair.shouldPromptClosure { info -> Bool in
            SKStoreReviewController.requestReview()
            return false
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
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
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
