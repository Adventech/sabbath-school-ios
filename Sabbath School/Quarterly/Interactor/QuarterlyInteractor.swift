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

import FirebaseStorage
import FontBlaster
import Unbox
import Zip

class QuarterlyInteractor: FirebaseDatabaseInteractor, QuarterlyInteractorInputProtocol {
    weak var presenter: QuarterlyInteractorOutputProtocol?
    weak var languageInteractor = LanguageInteractor()
    
    override func configure(){
        super.configure()
        print("YES")
        
        languageInteractor?.configure()
        languageInteractor?.presenter = self
    }
    
    func retrieveQuarterliesForLanguage(language: QuarterlyLanguage){
        database?.child(Constants.Firebase.quarterlies).child(language.code).observe(.value, with: { [weak self] (snapshot) in
            guard let json = snapshot.value as? [[String: AnyObject]] else { return }
            
            do {
                let items: [Quarterly] = try unbox(dictionaries: json)
                self?.presenter?.didRetrieveQuarterlies(quarterlies: items)
            } catch let error {
                self?.presenter?.onError(error)
            }
        }) { [weak self] (error) in
            self?.presenter?.onError(error)
        }
    }
    
    func retrieveQuarterlies() {
        guard let dictionary = UserDefaults.standard.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? [String: Any] else {
            return (languageInteractor?.retrieveLanguages())!
        }
        
        let language: QuarterlyLanguage = try! unbox(dictionary: dictionary)
        retrieveQuarterliesForLanguage(language: language)
    }
    
    private func checkifReaderBundleNeeded(){
        let storage = Storage.storage()
        let gsReference = storage.reference(forURL: Constants.Firebase.Storage.ReaderPath.stage)
        
        gsReference.getMetadata { [weak self] (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if String(describing: metadata?.timeCreated?.timeIntervalSince1970) != latestReaderBundleTimestamp() {
                    self?.downloadReaderBundle(metadata: metadata!)
                }
            }
        }

    }
    
    private func downloadReaderBundle(metadata: StorageMetadata){
        let storage = Storage.storage()
        let gsReference = storage.reference(forURL: Constants.Firebase.Storage.ReaderPath.stage)
        var localURL = Constants.Path.readerBundleZip
        
        _ = gsReference.write(toFile: localURL) { [weak self] (url, error) in
            if let error = error {
                self?.presenter?.onError(error)
            } else {
                do {
                    UserDefaults.standard.set(String(describing: metadata.timeCreated?.timeIntervalSince1970), forKey: Constants.DefaultKey.latestReaderBundleTimestamp)
                    var unzipDirectory = try Zip.quickUnzipFile(localURL)
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try localURL.setResourceValues(resourceValues)
                    try unzipDirectory.setResourceValues(resourceValues)
                    FontBlaster.blast()
                } catch {
                    print("unzipping error")
                }
            }
        }
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
        
        languageInteractor?.saveLanguage(language: currentLanguage)
        retrieveQuarterliesForLanguage(language: currentLanguage)
    }
    
    func didSelectLanguage(language: QuarterlyLanguage) { }
}
