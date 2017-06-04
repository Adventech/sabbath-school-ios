//
//  LoginController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-27.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import GoogleSignIn
import UIKit

class LoginController: ASViewController<ASDisplayNode>, LoginControllerProtocol {
    var loginNode: LoginNode { return node as! LoginNode }
    var presenter: LoginPresenterProtocol?
    
    init() {
        super.init(node: LoginNode())
        
        loginNode.anonymousButton.addTarget(self, action: #selector(loginAction(sender:)), forControlEvents: .touchUpInside)
        loginNode.googleButton.addTarget(self, action: #selector(loginAction(sender:)), forControlEvents: .touchUpInside)
        loginNode.facebookButton.addTarget(self, action: #selector(loginAction(sender:)), forControlEvents: .touchUpInside)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.configure()
    }
    
    func loginAction(sender: LoginButton) {
        switch sender.type {
        case .facebook:
            presenter?.loginActionFacebook()
        case .google:
            presenter?.loginActionGoogle()
        case .anonymous:
            presenter?.loginActionAnonymous()
        }
    }
}

extension LoginController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("Stop activity indicator")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true)
    }
}
