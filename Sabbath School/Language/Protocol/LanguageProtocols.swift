//
//  LanguageProtocols.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol LanguagePresenterProtocol: class {
    var controller: LanguageControllerProtocol? { get set }
    var interactor: LanguageInteractorInputProtocol? { get set }
    var wireFrame: LanguageWireFrameProtocol? { get set }
    var didSelectLanguageHandler: ()-> Void? { get set }
    
    func configure()
}

protocol LanguageControllerProtocol: class {
    var presenter: LanguagePresenterProtocol & LanguageInteractorOutputProtocol { get set }
    func showLanguages(languages: [QuarterlyLanguage])
}

protocol LanguageWireFrameProtocol: class {
    static func createLanguageModule(size: CGSize?, transitioningDelegate: UIViewControllerTransitioningDelegate?, didSelectLanguageHandler: @escaping ()-> Void?) -> ASNavigationController
}

protocol LanguageInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveLanguages(languages: [QuarterlyLanguage])
    func didSelectLanguage(language: QuarterlyLanguage)
}

protocol LanguageInteractorInputProtocol: class {
    var presenter: LanguageInteractorOutputProtocol? { get set }
    
    func configure()
    func retrieveLanguages()
    func saveLanguage(language: QuarterlyLanguage)
}
