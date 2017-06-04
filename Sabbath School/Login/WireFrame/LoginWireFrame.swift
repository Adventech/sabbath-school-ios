//
//  LoginNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-25.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LoginWireFrame: LoginWireFrameProtocol {
    class func createLoginModule() -> ASViewController<ASDisplayNode> {
        let controller: LoginControllerProtocol = LoginController()
        let presenter:  LoginPresenterProtocol & LoginInteractorOutputProtocol = LoginPresenter()
        let wireFrame:  LoginWireFrameProtocol = LoginWireFrame()
        let interactor: LoginInteractorInputProtocol = LoginInteractor()
        
        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return controller as! ASViewController<ASDisplayNode>
    }
    
    func presentQuarterlyScreen(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        UIView.transition(with: appDelegate.window!,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { appDelegate.window!.rootViewController = QuarterlyWireFrame.createQuarterlyModule() },
                          completion: nil)
    }
}
