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
import Foundation
import Cache

class QuarterlyInteractor: QuarterlyInteractorInputProtocol {
    weak var presenter: QuarterlyInteractorOutputProtocol?
    var languageInteractor = LanguageInteractor()
    private var storage: Storage<String, [Quarterly]>?
    
    init () {
        self.configure()
    }

    func configure() {
        languageInteractor.configure()
        languageInteractor.presenter = self
        self.storage = APICache.storage?.transformCodable(ofType: [Quarterly].self)
    }

    func retrieveQuarterliesForLanguage(language: QuarterlyLanguage) {
        let url = "\(Constants.API.URL)/\(language.code)/quarterlies/index.json"
        if (try? self.storage?.existsObject(forKey: url)) != nil {
            if let quarterlies = try? self.storage?.entry(forKey: url) {
                self.presenter?.didRetrieveQuarterlies(quarterlies: quarterlies.object)
            }
        }
        
        API.session.request(url).responseDecodable(of: [Quarterly].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let quarterlies = response.value else {
                self.presenter?.onError(response.error)
                return
            }
            self.presenter?.didRetrieveQuarterlies(quarterlies: quarterlies)
            try? self.storage?.setObject(quarterlies, forKey: url)
        }
    }

    func retrieveQuarterlies() {
        guard let dictionary = Preferences.userDefaults.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? Data else {
            return languageInteractor.retrieveLanguages()
        }

        let language: QuarterlyLanguage = try! JSONDecoder().decode(QuarterlyLanguage.self, from: dictionary)
        retrieveQuarterliesForLanguage(language: language)
    }
}

extension QuarterlyInteractor: LanguageInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }

    func didRetrieveLanguages(languages: [QuarterlyLanguage]) {
        var currentLanguage = QuarterlyLanguage(code: "en", name: "English".localized())
        let systemLanguageCode = Locale.current.languageCode

        for language in languages where language.code == systemLanguageCode {
            currentLanguage = language
            break
        }

        languageInteractor.saveLanguage(language: currentLanguage)
        retrieveQuarterliesForLanguage(language: currentLanguage)
    }

    func didSelectLanguage(language: QuarterlyLanguage) { }
}
