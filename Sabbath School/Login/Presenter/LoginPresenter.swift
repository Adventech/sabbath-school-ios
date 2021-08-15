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

import AuthenticationServices
import CryptoKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import SwiftMessages

class LoginPresenter: NSObject, LoginPresenterProtocol {
    var controller: LoginControllerProtocol?
    var wireFrame: LoginWireFrameProtocol?
    var interactor: LoginInteractorInputProtocol?
    var currentNonce: String?

    func configure() {
        // interactor?.configure()
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
//        GIDSignIn.sharedInstance().delegate = self
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
        let loginManager = LoginManager()
        let viewController = controller as? UIViewController

        loginManager.logIn(permissions: [.publicProfile, .email], viewController: viewController) { [weak self] (loginResult) in
            switch loginResult {
            case .failed(let error):
                self?.onError(error)
            case .cancelled:
                self?.onError("Cancelled" as? Error)
            case .success(_, _, let accessToken):
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken!.tokenString)
                self?.performFirebaseLogin(credential: credential)
            }
        }
    }

    func loginActionGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: controller as! UIViewController) { [weak self] user, error in
            if let error = error {
                self?.onError(error)
                return
            }

            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
              return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)

            self?.performFirebaseLogin(credential: credential)
          }
    }
    
    @available(iOS 13, *)
    func loginActionApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        self.currentNonce = randomNonceString()
        request.nonce = sha256(currentNonce!)
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
    }

    func performFirebaseLogin(credential: AuthCredential) {
        // Configuration.setAuthAccessGroup()
        Auth.auth().signIn(with: credential) { [weak self] (_, error) in
            if error != nil {
                self?.onError(error)
                return
            } else {
                self?.onSuccess()
            }
        }
    }
    
    @available(iOS 13, *)
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
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

//extension LoginPresenter: GIDSignInDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//        if let error = error {
//            onError(error)
//            return
//        }
//
//        let authentication = user.authentication
//        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
//                                                       accessToken: (authentication?.accessToken)!)
//        performFirebaseLogin(credential: credential)
//    }
//
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//    }
//}

extension LoginPresenter: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // return the current view window
        return (self.controller as! LoginController).view.window!
    }
}

extension LoginPresenter: ASAuthorizationControllerDelegate {
    @available(iOS 13, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        self.onError(error)
    }
    
    @available(iOS 13, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            Preferences.userDefaults.set(appleIDCredential.user, forKey: Constants.DefaultKey.appleAuthorizedUserIdKey)
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }

            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            self.performFirebaseLogin(credential: firebaseCredential)
        }
    }
}
