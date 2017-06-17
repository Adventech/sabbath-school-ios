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
    guard let lastQuarterlyIndex = UserDefaults.standard.value(forKey: Constants.DefaultKey.lastQuarterlyIndex) as? String else {
        return ""
    }
    return lastQuarterlyIndex
}

func currentTheme() -> String {
    guard let theme = UserDefaults.standard.value(forKey: Constants.DefaultKey.readingOptionsTheme) as? String else {
        return ""
    }
    return theme
}

func currentTypeface() -> String {
    guard let typeface = UserDefaults.standard.value(forKey: Constants.DefaultKey.readingOptionsTypeface) as? String else {
        return ""
    }
    return typeface
}

func currentSize() -> String {
    guard let size = UserDefaults.standard.value(forKey: Constants.DefaultKey.readingOptionsSize) as? String else {
        return ""
    }
    return size
}

func firstRun() -> Bool {
    guard let _ = UserDefaults.standard.value(forKey: Constants.DefaultKey.firstRun) as? Bool else {
        return true
    }
    return false
}


func reminderStatus() -> Bool {
    guard let status = UserDefaults.standard.value(forKey: Constants.DefaultKey.settingsReminderStatus) as? Bool else {
        return false
    }
    return status
}

func reminderTime() -> String {
    guard let time = UserDefaults.standard.value(forKey: Constants.DefaultKey.settingsReminderTime) as? String else {
        return ""
    }
    return time
}
