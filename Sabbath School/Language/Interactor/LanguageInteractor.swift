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

import Alamofire
import Cache
import Foundation

class LanguageInteractor: LanguageInteractorInputProtocol {
    weak var presenter: LanguageInteractorOutputProtocol?
    private var storage: Storage<String, [QuarterlyLanguage]>?

    func configure() {
        self.storage = APICache.storage?.transformCodable(ofType: [QuarterlyLanguage].self)
    }

    func retrieveLanguages() {
        let key = "\(Constants.API.URL)/languages/index.json"
        if (try? self.storage?.existsObject(forKey: key)) != nil {
            if let languages = try? self.storage?.entry(forKey: key) {
                self.presenter?.didRetrieveLanguages(languages: languages.object)
            }
        }

        API.session.request(key).responseDecodable(of: [QuarterlyLanguage].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let languages = response.value else {
                self.presenter?.onError(response.error)
                return
            }
            self.presenter?.didRetrieveLanguages(languages: languages)
            try? self.storage?.setObject(languages, forKey: key)
        }
    }

    func saveLanguage(language: QuarterlyLanguage) {
        let dictionary = try! JSONEncoder().encode(language)
        Preferences.userDefaults.set(dictionary, forKey: Constants.DefaultKey.quarterlyLanguage)
        Configuration.reloadAllWidgets()
    }
}
