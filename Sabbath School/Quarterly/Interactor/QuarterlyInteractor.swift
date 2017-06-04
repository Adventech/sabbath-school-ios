//
//  QuarterlyInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

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
