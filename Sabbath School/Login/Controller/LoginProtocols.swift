//
//  LoginProtocols.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-27.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import Firebase

protocol LoginPresenterProtocol: class {
    var controller: LoginControllerProtocol? { get set }
    var interactor: LoginInteractorInputProtocol? { get set }
    var wireFrame: LoginWireFrameProtocol? { get set }
    
    func configure()
    func loginActionAnonymous()
    func loginActionGoogle()
    func loginActionFacebook()
}

protocol LoginControllerProtocol: class {
    var presenter: LoginPresenterProtocol? { get set }
}

protocol LoginWireFrameProtocol: class {
    static func createLoginModule() -> ASViewController<ASDisplayNode>
    func presentQuarterlyScreen()
}

protocol LoginInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func onSuccess()
}

protocol LoginInteractorInputProtocol: class {
    var presenter: LoginInteractorOutputProtocol? { get set }
    
    func configure()
    func setupGoogleLogin()
    func setupFacebookLogin()
    func loginAnonymous()
    func loginGoogle()
    func loginFacebook()
    func performFirebaseLogin(credential: AuthCredential)
}
