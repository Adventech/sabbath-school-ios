//
//  LoginPresenter.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-27.
//  Copyright © 2017 Adventech. All rights reserved.
//

import SwiftMessages

class LoginPresenter: LoginPresenterProtocol {
    var controller: LoginControllerProtocol?
    var wireFrame: LoginWireFrameProtocol?
    var interactor: LoginInteractorInputProtocol?
    
    func configure(){
        interactor?.configure()
    }
    
    func loginActionAnonymous() {
        interactor?.loginAnonymous()
    }
    
    func loginActionFacebook(){
        interactor?.loginFacebook()
    }
    
    func loginActionGoogle() {
        // TODO: - Show loading indicator
        
        interactor?.loginGoogle()
    }
}

extension LoginPresenter: LoginInteractorOutputProtocol {
    func onSuccess(){
        wireFrame?.presentQuarterlyScreen()
    }
    
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .seconds(seconds: 3)
        
        let messageView = MessageView.viewFromNib(layout: .CardView)
        messageView.button?.isHidden = true
        messageView.bodyLabel?.font = R.font.latoBold(size: 17)
        messageView.configureTheme(.warning)
        messageView.configureContent(title: "", body: "There was an error during login")
        SwiftMessages.show(config: config, view: messageView)
        
    }
}
