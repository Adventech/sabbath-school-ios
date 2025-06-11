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

import Alamofire
import AuthenticationServices
import FontBlaster
import GoogleSignIn
import UIKit
import StoreKit
import WidgetKit
import PSPDFKit
import SwiftUI
import Nuke

class Configuration: NSObject {
    static var window: UIWindow?
    private static var screenSizeMonitor = ScreenSizeMonitor()
    private static var themeManager = ThemeManager()
    
    static func configureUI() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white | .black
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFontMetrics.default.scaledFont(for: UIFont(name: "Lato-Black", size: 36)!)
        ]
        
        appearance.largeTitleTextAttributes = attrs
        
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        
        UINavigationBar.appearance().standardAppearance = compactAppearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
    }
    
    static func configurePDF() {
        SDK.setLicenseKey("cJGk5VhG4CHpFwBMb0qi8Y93Ac2y4XnKQlN166tNY6-N3pQQGrBTxVzbGwG3afxZ4dIEXSyZgJRs6kgai-Uq_N6oYsuxEchhj5ANVamABFWDRTVfEqNNl1Tx9rpp-Xnno8Q2dbYpMlAiAcnLYfjIfX9iWe8DSp-G9f7XapAE4f9Hf5freAttn5dThUxB-tQLgxK4kpH0HE_WxWjQB4wqW6XIv7Nh8PYXdJ8rYagOBLuw8ze2gyhzkxIkUNtNEHw6XpwS30RQjC-OJZsmle5DQklmWDtVXdA5cI60B3_WyK5zIQP39FAgntA7_DSv57AJRypjHHW2URyZTqH3b-7lCYsZgHbZzT75Y9G5k_XUTitiQH5xCg5tgdVylj_1jLc8Vt-ryjKzC95fDwzEJgCU2p12dR-JVNMAOq6iAYGDWQFJeGJkuZztPa38QqfM3eXxxLgZ8Fookb6mbF2IArWggnouAQombQnvSvVrNcD-28NS6cDms4KkRs2PrJCx9wDilgC70iGbhbdD3oFonjkClLL51KvbA8KMbKsJAVzE415gbTJ8L0U2QC6q2FbZ8XauTCczx5RRAg-34OoGigRf8HyM-QWNTU_IqAZv1LMqCxk=",
                          options: [.fileCoordinationEnabled: false])
    }
    
    static func configureMisc() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    static func configureCache() {
        ConfigurationShared.configureCache()
        
        let dataCache = try! DataCache(name: Constants.DefaultKey.appGroupName)
        dataCache.sizeLimit = 200 * 1024 * 1024
        
        ImagePipeline.shared = ImagePipeline {
            $0.dataLoader = DataLoader()
            $0.dataCache = dataCache
            $0.imageCache = ImageCache.shared
        }
    }
    
    static func clearAllCache() {
        UIApplication.shared.shortcutItems = []
        Spotlight.clearSpotlight()
        
        URLCache.shared.removeAllCachedResponses()
        ImageCache.shared.removeAll()
        
        if let dataCache = try? DataCache(name: Constants.DefaultKey.appGroupName) {
            dataCache.removeAll()
        }

        DispatchQueue.main.async {
            ResourceInfoViewModel.clearAllCache()
            ResourceFeedViewModel.clearAllCache()
            AuthorFeedViewModel.clearAllCache()
            CategoryFeedViewModel.clearAllCache()
            DocumentViewModel.clearAllCache()
            SyncManager.clearAllCache()
            DownloadManager.clearAllCache()
            
            Downloader.removeAllDownloadedFiles()
        }
    }
    
    static func configureFontblaster() {
        FontBlaster.blast()
    }
    
    static func configurePreferences() {        
        Preferences.userDefaults.register(defaults: [
            Constants.DefaultKey.tintColor: UIColor.baseBlue.hex(),
            Constants.DefaultKey.settingsReminderStatus: true,
            Constants.DefaultKey.settingsDefaultReminderTime: Constants.DefaultKey.settingsReminderTime
        ])

        if Helper.firstRun() {
            Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.firstRun)
            Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.migrationToAppGroups)
            NotificationsManager.setupLocalNotifications()
        }
    }
    
    static func configureNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
    }
    
    static func reloadAllWidgets() {
        #if arch(arm64) || arch(i386) || arch(x86_64)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
