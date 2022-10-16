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

class BibleInteractor: BibleInteractorInputProtocol {
    weak var presenter: BibleInteractorOutputProtocol?

    func configure() {}

    func preferredBibleVersionFor(bibleVerses: [BibleVerses]) -> String? {
        if let bibleVersion = Preferences.userDefaults.value(forKey: Preferences.getPreferredBibleVersionKey()) as? String {
            return bibleVersion
        }

        guard let versionName = bibleVerses.first?.name else { return nil }
        Preferences.userDefaults.set(versionName, forKey: Preferences.getPreferredBibleVersionKey())
        return versionName
    }

    func retrieveBibleVerse(bibleVerses: [BibleVerses], verse: String) {
        if let versionName = preferredBibleVersionFor(bibleVerses: bibleVerses),
            let bibleVersion = bibleVerses.filter({$0.name == versionName}).first,
            let openVerse = bibleVersion.verses?[verse] {
            presenter?.didRetrieveBibleVerse(content: openVerse)
        }
    }
}
