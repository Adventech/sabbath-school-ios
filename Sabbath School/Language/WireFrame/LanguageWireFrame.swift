//
//  LanguageWireFrame.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class LanguageWireFrame: LanguageWireFrameProtocol {
    class func createLanguageModule(size: CGSize?, transitioningDelegate: UIViewControllerTransitioningDelegate?, didSelectLanguageHandler: @escaping ()-> Void?) -> ASNavigationController {
        let controller: LanguageControllerProtocol = LanguageController()
        let presenter:  LanguagePresenterProtocol & LanguageInteractorOutputProtocol = LanguagePresenter()
        let wireFrame:  LanguageWireFrameProtocol = LanguageWireFrame()
        let interactor: LanguageInteractorInputProtocol = LanguageInteractor()
        
        presenter.didSelectLanguageHandler = didSelectLanguageHandler
        
        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        let navigation = ASNavigationController(rootViewController: controller as! UIViewController)
        
        navigation.transitioningDelegate = transitioningDelegate
        navigation.modalPresentationStyle = .custom
        navigation.preferredContentSize = size!
        
        return navigation 
    }
}
