/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

import UIKit

class SettingsPresenter: NSObject, SettingsPresenterProtocol {
    
    weak var controller: SettingsControllerProtocol?
    
    private var interactor: SettingsInteractorInputProtocol?
    
    override init() {
        super.init()
        let interactor = SettingsInteractor()
        interactor.presenter = self
        self.interactor = interactor
    }
    
    func presentRemoveAccountConfirmation() {
        let alertController = UIAlertController(
            title: "Delete account?".localized(),
            message: "By deleting your account all your data, such as comments and highlights will be permanently deleted. Are you sure you want to proceed?".localized(),
            preferredStyle: .alert
        )

        let no = UIAlertAction(title: "No".localized(), style: .default, handler: nil)
        no.accessibilityLabel = "removeAccountNo"

        let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { _ in
            self.interactor?.removeAccount()
//            SettingsController.logOut()
        }
        yes.accessibilityLabel = "removeAccountYes"

        alertController.addAction(no)
        alertController.addAction(yes)
        alertController.accessibilityLabel = "removeAccount"

        (controller as? UIViewController)?.present(alertController, animated: true, completion: nil)
    }
}

extension SettingsPresenter: SettingsInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print("SSDEBUG", error?.localizedDescription ?? "Unknown")
    }
    
    func onSuccess() {
        SettingsController.logOut()
    }
}
