/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import FacebookCore
import FacebookLogin
import Firebase
import GoogleSignIn

class LoginInteractor: NSObject, LoginInteractorInputProtocol {
    weak var presenter: LoginInteractorOutputProtocol?

    func configure() {
        setupGoogleLogin()
    }

    func setupGoogleLogin() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    func setupFacebookLogin() {

    }

    func loginAnonymous() {
        let alertController = UIAlertController(
            title: "Login anonymously?".localized(),
            message: "By logging in anonymously you will not be able to synchronize your data, such as comments and highlights, across devices or after uninstalling application. Are you sure you want to proceed?".localized(),
            preferredStyle: .alert
        )

        let no = UIAlertAction(title: "No".localized(), style: .default, handler: nil)
        no.accessibilityLabel = "loginAnonymousOptionNo"

        let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { [weak self] (_) in
            Auth.auth().signInAnonymously(completion: { [weak self] (_, error) in
                if let error = error {
                    self?.presenter?.onError(error)
                } else {
                    self?.presenter?.onSuccess()
                }
            })
        }
        yes.accessibilityLabel = "loginAnonymousOptionYes"

        alertController.addAction(no)
        alertController.addAction(yes)
        alertController.accessibilityLabel = "loginAnonymous"

        ((self.presenter as? LoginPresenter)?.controller as? UIViewController)?.present(alertController, animated: true, completion: nil)

    }

    func loginGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }

    func loginFacebook() {
        let loginManager = LoginManager()

        loginManager.logIn(readPermissions:[ReadPermission.publicProfile, ReadPermission.email], viewController: (self.presenter as? LoginPresenter)?.controller as? UIViewController, completion: { [weak self] (loginResult) in
            switch loginResult {
            case .failed(let error):
                self?.presenter?.onError(error)
            case .cancelled:
                self?.presenter?.onError("Cancelled" as? Error)
            case .success(_, _, let accessToken):
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                self?.performFirebaseLogin(credential: credential)
            }
        })
    }

    func performFirebaseLogin(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] (_, error) in
            if error != nil {
                self?.presenter?.onError(error)
                return
            } else {
                self?.presenter?.onSuccess()
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
