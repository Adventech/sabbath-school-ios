//
//  LoginInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-27.
//  Copyright © 2017 Adventech. All rights reserved.
//

import FacebookCore
import FacebookLogin
import Firebase
import GoogleSignIn

class LoginInteractor: NSObject, LoginInteractorInputProtocol {
    weak var presenter: LoginInteractorOutputProtocol?
    
    func configure(){
        setupGoogleLogin()
    }
    
    func setupGoogleLogin(){
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    func setupFacebookLogin(){
        
    }
    
    func loginAnonymous(){
        let alertController = UIAlertController(
            title: "Login anonymously?",
            message: "By logging in anonymously you will not be able to synchronize your data, such as comments and highlights, across devices or after uninstalling application. Are you sure you want to proceed?",
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive) { (action) in
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let error = error {
                    self.presenter?.onError(error)
                } else {
                    self.presenter?.onSuccess()
                }
            })
        })
        
        ((self.presenter as? LoginPresenter)?.controller as? UIViewController)?.present(alertController, animated: true, completion: nil)
        
    }
    
    func loginGoogle(){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginFacebook(){
        let loginManager = LoginManager()
        
        loginManager.logIn([ReadPermission.publicProfile, ReadPermission.email], viewController: (self.presenter as? LoginPresenter)?.controller as? UIViewController, completion: { (loginResult) in
            switch loginResult {
            case .failed(let error):
                self.presenter?.onError(error)
            case .cancelled:
                self.presenter?.onError("Cancelled" as? Error)
            case .success(_, _, let accessToken):
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                self.performFirebaseLogin(credential: credential)
            }
        })
    }
    
    func performFirebaseLogin(credential: AuthCredential){
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                self.presenter?.onError(error)
                return
            } else {
                self.presenter?.onSuccess()
            }
        }
    }
}

extension LoginInteractor: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            self.presenter?.onError(error)
            return
        }
        
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                       accessToken: (authentication?.accessToken)!)
        performFirebaseLogin(credential: credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
}
