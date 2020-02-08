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

import SwiftMessages

class LoginPresenter: LoginPresenterProtocol {
    var controller: LoginControllerProtocol?
    var wireFrame: LoginWireFrameProtocol?
    var interactor: LoginInteractorInputProtocol?

    func configure() {
        interactor?.configure()
    }

    func loginActionAnonymous() {
        interactor?.loginAnonymous()
    }

    func loginActionFacebook() {
        interactor?.loginFacebook()
    }

    func loginActionGoogle() {
        interactor?.loginGoogle()
    }
}

extension LoginPresenter: LoginInteractorOutputProtocol {
    func onSuccess() {
        wireFrame?.presentQuarterlyScreen()
    }

    func onError(_ error: Error?) {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar.rawValue)
        config.duration = .seconds(seconds: 3)

        let messageView = MessageView.viewFromNib(layout: .CardView)
        messageView.button?.isHidden = true
        messageView.bodyLabel?.font = R.font.latoBold(size: 17)
        messageView.configureTheme(.warning)
        messageView.configureContent(title: "", body: "There was an error during login".localized())
        SwiftMessages.show(config: config, view: messageView)

    }
}
