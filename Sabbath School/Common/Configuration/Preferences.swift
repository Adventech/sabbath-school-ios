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

import Foundation
import UIKit
import PSPDFKitUI

struct Preferences {
    static var userDefaults: UserDefaults {
        return PreferencesShared.userDefaults
    }
    
    static func firebaseUserMigrated() -> Bool {
        return Preferences.userDefaults.bool(forKey: Constants.DefaultKey.accountFirebaseMigrated)
    }

    static func migrateUserDefaultsToAppGroups() {
        let userDefaults = UserDefaults.standard
        let groupDefaults = UserDefaults(suiteName: Constants.DefaultKey.appGroupName)
        
        if let groupDefaults = groupDefaults {
            if !groupDefaults.bool(forKey: Constants.DefaultKey.migrationToAppGroups) {
                for (key, value) in userDefaults.dictionaryRepresentation() {
                    groupDefaults.set(value, forKey: key)
                }
                groupDefaults.set(true, forKey: Constants.DefaultKey.migrationToAppGroups)
                groupDefaults.synchronize()
            } else {
                print("No need to migrate defaults")
            }
        } else {
            print("Unable to create NSUserDefaults with given app group")
        }
        
    }
    
    static func currentLanguage() -> QuarterlyLanguage {
        return PreferencesShared.currentLanguage()
    }
    
    static func currentQuarterly() -> String {
        return PreferencesShared.currentQuarterly()
    }
    
    static func currentTheme() -> ReaderStyle.Theme {
        guard let rawTheme = Preferences.userDefaults.string(forKey: Constants.DefaultKey.readingOptionsTheme),
            let theme = ReaderStyle.Theme(rawValue: rawTheme) else {
            if Preferences.getSettingsTheme() == Theme.Dark.rawValue {
                return .dark
            }
            return .light
        }
        return theme
    }
    
    static func darkModeEnable() -> Bool {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }
    
    static func currentTypeface() -> ReaderStyle.Typeface {
        guard let rawTypeface = Preferences.userDefaults.string(forKey: Constants.DefaultKey.readingOptionsTypeface),
            let typeface = ReaderStyle.Typeface(rawValue: rawTypeface) else {
            return .lato
        }
        return typeface
    }
    
    static func currentSize() -> ReaderStyle.Size {
        guard let rawSize = Preferences.userDefaults.string(forKey: Constants.DefaultKey.readingOptionsSize),
            let size = ReaderStyle.Size(rawValue: rawSize) else {
            return .medium
        }
        return size
    }
    
    static func reminderStatus() -> Bool {
        return Preferences.userDefaults.bool(forKey: Constants.DefaultKey.settingsReminderStatus)
    }

    static func reminderTime() -> String {
        guard let time = Preferences.userDefaults.string(forKey: Constants.DefaultKey.settingsReminderTime) else {
            return Constants.DefaultKey.settingsDefaultReminderTime
        }
        return time
    }
    
    static func latestReaderBundleTimestamp() -> String {
        guard let timestamp = Preferences.userDefaults.string(forKey: Constants.DefaultKey.latestReaderBundleTimestamp) else {
            return ""
        }
        return timestamp
    }

    static func getSettingsTheme() -> String {
        guard let theme = Preferences.userDefaults.string(forKey: Constants.DefaultKey.settingsTheme) else {
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    return Theme.Dark.rawValue
                }
            }
            return Theme.Light.rawValue
        }
        return theme
    }

    static func gcPopupStatus() -> Bool {
        return Preferences.userDefaults.bool(forKey: Constants.DefaultKey.gcPopup)
    }
    
    static func getPreferredBibleVersionKey() -> String {
        return Constants.DefaultKey.preferredBibleVersion + Preferences.currentLanguage().code
    }
    
    static func getPdfPageTransition() -> PageTransition {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationPageTransition) != nil
        let pageTransition = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationPageTransition)
        return exists ? PageTransition(rawValue: UInt(pageTransition))! : PageTransition.scrollContinuous
    }
    
    static func getPdfPageMode() -> PageMode {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationPageMode) != nil
        let pageMode = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationPageMode)
        return exists ? PageMode(rawValue: UInt(pageMode))! : PageMode.single
    }
    
    static func getPdfScrollDirection() -> ScrollDirection {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationScrollDirection) != nil
        let scrollDirection = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationScrollDirection)
        return exists ? ScrollDirection(rawValue: UInt(scrollDirection))! : ScrollDirection.vertical
    }
    
    static func getPdfSpreadFitting() -> PDFConfiguration.SpreadFitting {
        let exists = Preferences.userDefaults.object(forKey: Constants.DefaultKey.pdfConfigurationSpreadFitting) != nil
        let spreadFitting = Preferences.userDefaults.integer(forKey: Constants.DefaultKey.pdfConfigurationSpreadFitting)
        return exists ? PDFConfiguration.SpreadFitting(rawValue: spreadFitting)! : PDFConfiguration.SpreadFitting.fit
    }
    
    static func saveQuarterlyGroup(quarterlyGroup: QuarterlyGroup) -> Void {
        var existingGroups = Preferences.getQuarterlyGroups()
        
        if let index = existingGroups.firstIndex(where: { $0.name == quarterlyGroup.name }) {
            existingGroups.remove(at: index)
        }
        
        existingGroups.insert(quarterlyGroup, at: 0)
        
        do {
            let dictionary = try JSONEncoder().encode(existingGroups)
            Preferences.userDefaults.set(dictionary, forKey: "\(Constants.DefaultKey.quarterlyGroups)\(currentLanguage().code)")
        } catch {
            return
        }
    }
    
    static func getQuarterlyGroups() -> [QuarterlyGroup] {
        if let quarterliesGroupData = Preferences.userDefaults.value(forKey: "\(Constants.DefaultKey.quarterlyGroups)\(currentLanguage().code)") as? Data {
            do {
                let quarterliesGroup: [QuarterlyGroup] = try JSONDecoder().decode(Array<QuarterlyGroup>.self, from: quarterliesGroupData)
                return quarterliesGroup
            } catch {}
        }
        return []
    }
}
