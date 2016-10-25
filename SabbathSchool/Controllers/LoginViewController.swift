//
//  LoginViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 23/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import GoogleSignIn

class LoginViewController: ASViewController<ASDisplayNode> {
    var loginNode: LoginNode { return node as! LoginNode}
    
    // MARK: - Init
    
    init() {
        super.init(node: LoginNode())
        
        loginNode.facebookButton.addTarget(self, action: #selector(loginAction(sender:)), forControlEvents: .touchUpInside)
        loginNode.googleButton.addTarget(self, action: #selector(loginAction(sender:)), forControlEvents: .touchUpInside)
        loginNode.anonymousButton.addTarget(self, action: #selector(loginAction(sender:)), forControlEvents: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func loadView() {
        super.loadView()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    // MARK: - Actions
    
    func loginAction(sender: SignInButtonNode) {
        switch sender.type {
        case .facebook:
            print("facebook")
        case .google:
            print("google")
            GIDSignIn.sharedInstance().signIn()
        case .anonymous:
            print("anonymous")
        }
    }
}

extension LoginViewController: GIDSignInUIDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("Stop activity indicator")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss()
    }
}
