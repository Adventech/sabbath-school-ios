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

class GroupedQuarterlyWireFrame: GroupedQuarterlyWireFrameProtocol {
    class func createQuarterlyModule(initiateOpen: Bool = false) -> ASNavigationController {
        let controller: GroupedQuarterlyControllerProtocol = GroupedQuarterlyController()
        let presenter: GroupedQuarterlyPresenterProtocol & QuarterlyInteractorOutputProtocol = GroupedQuarterlyPresenter()
        let wireFrame: GroupedQuarterlyWireFrameProtocol = GroupedQuarterlyWireFrame()
        let interactor: QuarterlyInteractorInputProtocol = QuarterlyInteractor()
        
        controller.initiateOpen = initiateOpen
        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        interactor.presenter = presenter

        return ASNavigationController(rootViewController: controller as! UIViewController)
    }

    func presentLessonScreen(view: GroupedQuarterlyControllerProtocol, quarterlyIndex: String, initiateOpenToday: Bool = false) {
        let lessonScreen = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: initiateOpenToday)
        self.showLessonScreen(view: view, lessonScreen: lessonScreen)
    }
    
    func showLessonScreen(view: GroupedQuarterlyControllerProtocol, lessonScreen: LessonController) {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        if let sourceView = view as? UIViewController {
            sourceView.show(lessonScreen, sender: nil)
        }
    }

    static func presentLoginScreen() {
        let loginScreen = LoginWireFrame.createLoginModule()

        UIView.transition(with: Configuration.window!,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { Configuration.window!.rootViewController = loginScreen },
                          completion: nil)
    }
}
