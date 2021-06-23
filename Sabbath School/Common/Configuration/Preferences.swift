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

struct Preferences {
    static var userDefaults: UserDefaults {
        return PreferencesShared.userDefaults
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
                print("Successfully migrated defaults")
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
}
