//
//  BibleInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Foundation

class BibleInteractor: BibleInteractorInputProtocol {
    weak var presenter: BibleInteractorOutputProtocol?
    
    func configure() {}
    
    func preferredBibleVersionFor(bibleVerses: [BibleVerses]) -> String? {
        if let bibleVersion = UserDefaults.standard.value(forKey: Constants.DefaultKey.preferredBibleVersion) as? String {
            return bibleVersion
        }
        
        guard let versionName = bibleVerses.first?.name else { return nil }
        UserDefaults.standard.set(versionName, forKey: Constants.DefaultKey.preferredBibleVersion)
        return versionName
    }
    
    func retrieveBibleVerse(read: Read, verse: String){
        if let versionName = preferredBibleVersionFor(bibleVerses: read.bible),
            let bibleVersion = read.bible.filter({$0.name == versionName}).first,
            let openVerse = bibleVersion.verses[verse] {
            presenter?.didRetrieveBibleVerse(content: openVerse)
        }
    }
}
