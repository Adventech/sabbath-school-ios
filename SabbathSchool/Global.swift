//
//  Global.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 02/12/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import Foundation
import Unbox

// MARK: - Language for code

func currentLanguage() -> QuarterlyLanguage {
    guard let dictionary = UserDefaults.standard.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? [String: Any] else {
        return QuarterlyLanguage(code: "en", name: "English")
    }
    
    let language: QuarterlyLanguage = try! unbox(dictionary: dictionary)
    return language
}


func preferredBibleVersionFor(bibleVerses: [BibleVerses]) -> String? {
    if let bibleVersion = UserDefaults.standard.value(forKey: Constants.DefaultKey.preferredBibleVersion) as? String {
        return bibleVersion
    }
    
    guard let versionName = bibleVerses.first?.name else { return nil }
    UserDefaults.standard.set(versionName, forKey: Constants.DefaultKey.preferredBibleVersion)
    return versionName
}
