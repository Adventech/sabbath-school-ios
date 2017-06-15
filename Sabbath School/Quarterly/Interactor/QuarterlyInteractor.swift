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

import Unbox

class QuarterlyInteractor: FirebaseDatabaseInteractor, QuarterlyInteractorInputProtocol {
    weak var presenter: QuarterlyInteractorOutputProtocol?
    var languageInteractor = LanguageInteractor()
    
    override func configure(){
        super.configure()
        
        languageInteractor.configure()
        languageInteractor.presenter = self
    }
    
    func retrieveQuarterliesForLanguage(language: QuarterlyLanguage){
        database.child(Constants.Firebase.quarterlies).child(language.code).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [[String: AnyObject]] else { return }
            
            do {
                let items: [Quarterly] = try unbox(dictionaries: json)
                self.presenter?.didRetrieveQuarterlies(quarterlies: items)
            } catch let error {
                self.presenter?.onError(error)
            }
        }) { (error) in
            self.presenter?.onError(error)
        }
    }
    
    func retrieveQuarterlies() {
        guard let dictionary = UserDefaults.standard.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? [String: Any] else {
            return languageInteractor.retrieveLanguages()
        }
        
        let language: QuarterlyLanguage = try! unbox(dictionary: dictionary)
        retrieveQuarterliesForLanguage(language: language)
    }
}

extension QuarterlyInteractor: LanguageInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }
    
    func didRetrieveLanguages(languages: [QuarterlyLanguage]){
        var currentLanguage = QuarterlyLanguage(code: "en", name: "English")
        let systemLanguageCode = Locale.current.languageCode
        
        for language in languages {
            if language.code == systemLanguageCode {
                currentLanguage = language
                break
            }
        }
        
        languageInteractor.saveLanguage(language: currentLanguage)
        retrieveQuarterliesForLanguage(language: currentLanguage)
    }
    
    func didSelectLanguage(language: QuarterlyLanguage) { }
}
