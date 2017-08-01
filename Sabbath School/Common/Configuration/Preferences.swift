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
import Unbox

func currentLanguage() -> QuarterlyLanguage {
    guard let dictionary = UserDefaults.standard.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? [String: Any] else {
        return QuarterlyLanguage(code: "en", name: "English")
    }
    
    let language: QuarterlyLanguage = try! unbox(dictionary: dictionary)
    return language
}

func currentQuarterly() -> String {
    guard let lastQuarterlyIndex = UserDefaults.standard.string(forKey: Constants.DefaultKey.lastQuarterlyIndex) else {
        return ""
    }
    return lastQuarterlyIndex
}

func currentTheme() -> ReaderStyle.Theme {
    guard let rawTheme = UserDefaults.standard.string(forKey: Constants.DefaultKey.readingOptionsTheme),
        let theme = ReaderStyle.Theme(rawValue: rawTheme) else {
        return .light
    }
    return theme
}

func currentTypeface() -> ReaderStyle.Typeface {
    guard let rawTypeface = UserDefaults.standard.string(forKey: Constants.DefaultKey.readingOptionsTypeface),
        let typeface = ReaderStyle.Typeface(rawValue: rawTypeface)  else {
        return .lato
    }
    return typeface
}

func currentSize() -> ReaderStyle.Size {
    guard let rawSize = UserDefaults.standard.string(forKey: Constants.DefaultKey.readingOptionsSize),
        let size = ReaderStyle.Size(rawValue: rawSize) else {
        return .medium
    }
    return size
}

func firstRun() -> Bool {
    return UserDefaults.standard.bool(forKey: Constants.DefaultKey.firstRun)
}

func reminderStatus() -> Bool {
    return UserDefaults.standard.bool(forKey: Constants.DefaultKey.settingsReminderStatus)
}

func reminderTime() -> String {
    guard let time = UserDefaults.standard.string(forKey: Constants.DefaultKey.settingsReminderTime) else {
        return Constants.DefaultKey.settingsDefaultReminderTime
    }
    return time
}

func latestReaderBundleTimestamp() -> String {
    guard let timestamp = UserDefaults.standard.string(forKey: Constants.DefaultKey.latestReaderBundleTimestamp) else {
        return ""
    }
    return timestamp
}
