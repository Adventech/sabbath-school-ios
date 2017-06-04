//
//  LanguageInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import FirebaseDatabase
import Unbox
import Wrap

class LanguageInteractor: FirebaseDatabaseInteractor, LanguageInteractorInputProtocol {
    weak var presenter: LanguageInteractorOutputProtocol?
    
    override func configure(){
        database = Database.database().reference()
    }
    
    func retrieveLanguages() {
        database.child(Constants.Firebase.languages).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let json = snapshot.value as? [[String: AnyObject]] else { return }
            
            do {
                let items: [QuarterlyLanguage] = try unbox(dictionaries: json)
                self.presenter?.didRetrieveLanguages(languages: items)
            } catch let error {
                self.presenter?.onError(error)
            }
        })
    }
    
    func saveLanguage(language: QuarterlyLanguage){
        let dictionary: [String: Any] = try! wrap(language)
        UserDefaults.standard.set(dictionary, forKey: Constants.DefaultKey.quarterlyLanguage)
    }
}
