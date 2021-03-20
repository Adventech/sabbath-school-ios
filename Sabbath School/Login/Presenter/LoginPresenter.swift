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

import Firebase
import SwiftMessages
import FacebookCore
import FacebookLogin
import GoogleSignIn

class LoginPresenter: NSObject, LoginPresenterProtocol {
    var controller: LoginControllerProtocol?
    var wireFrame: LoginWireFrameProtocol?
    var interactor: LoginInteractorInputProtocol?

    func configure() {
        // interactor?.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    func loginActionAnonymous() {
        // interactor?.loginAnonymous()
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
                    self?.onError(error)
                } else {
                    self?.onSuccess()
                }
            })
        }
        yes.accessibilityLabel = "loginAnonymousOptionYes"

        alertController.addAction(no)
        alertController.addAction(yes)
        alertController.accessibilityLabel = "loginAnonymous"

        (controller as? UIViewController)?.present(alertController, animated: true, completion: nil)
    }

    func loginActionFacebook() {
        // interactor?.loginFacebook()
        let loginManager = LoginManager()
        let viewController = controller as? UIViewController

        loginManager.logIn(permissions: [.publicProfile, .email], viewController: viewController) { [weak self] (loginResult) in
            switch loginResult {
            case .failed(let error):
                self?.onError(error)
            case .cancelled:
                self?.onError("Cancelled" as? Error)
            case .success(_, _, let accessToken):
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                self?.performFirebaseLogin(credential: credential)
            }
        }
    }

    func loginActionGoogle() {
        // interactor?.loginGoogle()
        GIDSignIn.sharedInstance().signIn()
    }

    func performFirebaseLogin(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] (_, error) in
            if error != nil {
                self?.onError(error)
                return
            } else {
                self?.onSuccess()
            }
        }
    }
}

extension LoginPresenter: LoginInteractorOutputProtocol {
    func onSuccess() {
        wireFrame?.presentQuarterlyScreen()
    }

    func onError(_ error: Error?) {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .seconds(seconds: 3)

        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.button?.isHidden = true
        messageView.bodyLabel?.font = R.font.latoBold(size: 17)
        messageView.configureTheme(.warning)
        messageView.configureContent(title: "", body: "There was an error during login".localized())
        SwiftMessages.show(config: config, view: messageView)

    }
}

extension LoginPresenter: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            onError(error)
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
