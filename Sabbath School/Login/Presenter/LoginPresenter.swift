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

import Alamofire
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import SwiftMessages

enum LoginType {
    case google
    case apple
    case anonymous
    
    var param: String {
        switch self {
        case .google: return "google"
        case .apple: return "apple"
        case .anonymous: return "anonymous"
        }
    }
}

class LoginPresenter: NSObject, LoginPresenterProtocol {
    var controller: LoginControllerProtocol?
    var wireFrame: LoginWireFrameProtocol?
    var interactor: LoginInteractorInputProtocol?
    var currentNonce: String?

    func configure() {}

    func loginActionAnonymous() {
        let alertController = UIAlertController(
            title: "Login anonymously?".localized(),
            message: "By logging in anonymously you will not be able to synchronize your data, such as comments and highlights, across devices or after uninstalling application. Are you sure you want to proceed?".localized(),
            preferredStyle: .alert
        )

        let no = UIAlertAction(title: "No".localized(), style: .default, handler: nil)
        no.accessibilityLabel = "loginAnonymousOptionNo"

        let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { [weak self] (_) in
            self?.performLogin(credentials: ["a": "b"], loginType: .anonymous)
        }
        yes.accessibilityLabel = "loginAnonymousOptionYes"

        alertController.addAction(no)
        alertController.addAction(yes)
        alertController.accessibilityLabel = "loginAnonymous"

        (controller as? UIViewController)?.present(alertController, animated: true, completion: nil)
    }

    func loginActionGoogle() {
        let config = GIDConfiguration(clientID: Constants.API.GOOGLE_CLIENT_ID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: controller as! UIViewController) { [weak self] user, error in
            if let error = error {
                self?.onError(error)
                return
            }

            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
              return
            }
            
            self?.performLogin(credentials: [ "id_token": idToken ], loginType: .google)
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
    
    func performLogin(credentials: [String: Any], loginType: LoginType) {
        AF.request(
            "\(Constants.API.URL)/auth/signin/\(loginType.param)",
            method: .post,
            parameters: credentials,
            encoding: JSONEncoding.default
        ).responseDecodable(of: Account.self, decoder: Helper.SSJSONDecoder()) { response in
            switch response.result {
            case .success:
                let dictionary = try! JSONEncoder().encode(response.value)
                Preferences.userDefaults.set(dictionary, forKey: Constants.DefaultKey.accountObject)
                self.onSuccess()
            case let .failure(error):
                self.onError(error)
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
        Configuration.loginAnimated()
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

            self.performLogin(credentials: [ "id_token": idTokenString, "nonce": nonce ], loginType: .apple)
        }
    }
}
