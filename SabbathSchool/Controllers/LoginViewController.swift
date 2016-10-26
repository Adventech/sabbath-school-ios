//
//  LoginViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 23/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import GoogleSignIn
import FacebookCore
import FacebookLogin

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
            let loginManager = LoginManager()
            loginManager.logIn([.publicProfile, .email, .userFriends], viewController: self, completion: { (loginResult) in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(_, _, let accessToken):
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.finishLoginWith(credential: credential)
                }
            })
        case .google:
            GIDSignIn.sharedInstance().signIn()
            
        case .anonymous:
            let alertController = UIAlertController(title: "Login anonymously?", message: "By logging in anonymously you will not be able to synchronize your data, such as comments and highlights, across devices or after uninstalling application. Are you sure you want to proceed?", preferredStyle: .alert)
            
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.signInAnonymously()
            }
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            present(alertController, animated: true, completion: nil)
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
