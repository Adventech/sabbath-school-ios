//
//  QuarterlyProtocols.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol QuarterlyPresenterProtocol: class {
    var controller: QuarterlyControllerProtocol? { get set }
    var interactor: QuarterlyInteractorInputProtocol? { get set }
    var wireFrame: QuarterlyWireFrameProtocol? { get set }
    
    func configure()
    func presentLanguageScreen(size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate)
    func presentLessonScreen(quarterlyIndex: String)
    func presentQuarterlies()
}

protocol QuarterlyControllerProtocol: class {
    var presenter: QuarterlyPresenterProtocol? { get set }
    func showQuarterlies(quarterlies: [Quarterly])
    func retrieveQuarterlies()
}

protocol QuarterlyWireFrameProtocol: class {
    static func createQuarterlyModule() -> ASNavigationController
    func reloadQuarterlyModule()
    func presentLessonScreen(view: QuarterlyControllerProtocol, quarterlyIndex: String)
}

protocol QuarterlyInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveQuarterlies(quarterlies: [Quarterly])
}

protocol QuarterlyInteractorInputProtocol: class {
    var presenter: QuarterlyInteractorOutputProtocol? { get set }
    var languageInteractor: LanguageInteractor { get set }
    
    func configure()
    func retrieveQuarterlies()
    func retrieveQuarterliesForLanguage(language: QuarterlyLanguage)
}
