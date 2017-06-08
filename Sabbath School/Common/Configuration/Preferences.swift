//
//  Preferences.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-05.
//  Copyright © 2017 Adventech. All rights reserved.
//

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
