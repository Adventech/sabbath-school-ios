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

import AsyncDisplayKit

class QuarterlyWireFrame: QuarterlyWireFrameProtocol {
    class func createQuarterlyModule() -> ASNavigationController {
        let controller: QuarterlyControllerProtocol = QuarterlyController()
        let presenter: QuarterlyPresenterProtocol & QuarterlyInteractorOutputProtocol = QuarterlyPresenter()
        let wireFrame: QuarterlyWireFrameProtocol = QuarterlyWireFrame()
        let interactor: QuarterlyInteractorInputProtocol = QuarterlyInteractor()

        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        interactor.presenter = presenter

        return ASNavigationController(rootViewController: controller as! UIViewController)
    }

    func reloadQuarterlyModule() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        UIView.transition(with: appDelegate.window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { appDelegate.window!.rootViewController = QuarterlyWireFrame.createQuarterlyModule() },
                          completion: nil)
    }

    func presentLessonScreen(view: QuarterlyControllerProtocol, quarterlyIndex: String) {
        let lessonScreen = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex)

        if let sourceView = view as? UIViewController {
            sourceView.show(lessonScreen, sender: nil)
        }
    }

    static func presentLoginScreen() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let loginScreen = LoginWireFrame.createLoginModule()

        UIView.transition(with: appDelegate.window!,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { appDelegate.window!.rootViewController = loginScreen },
                          completion: nil)
    }
}
