//
//  LanguagePresenter.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class LanguagePresenter: LanguagePresenterProtocol {
    var controller: LanguageControllerProtocol?
    var wireFrame: LanguageWireFrameProtocol?
    var interactor: LanguageInteractorInputProtocol?
    var didSelectLanguageHandler: ()-> Void? = { return }
    
    func configure(){
        interactor?.configure()
        interactor?.retrieveLanguages()
    }
}

extension LanguagePresenter: LanguageInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }
    
    func didRetrieveLanguages(languages: [QuarterlyLanguage]){
        controller?.showLanguages(languages: languages)
    }
    
    func didSelectLanguage(language: QuarterlyLanguage) {
        interactor?.saveLanguage(language: language)
        (controller as! UIViewController).dismiss()
        didSelectLanguageHandler()
    }
}
