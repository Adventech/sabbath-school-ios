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

class LessonWireFrame: LessonWireFrameProtocol {
    class func createLessonModule(quarterlyIndex: String, initiateOpenToday: Bool = false) -> LessonController {
        let controller: LessonControllerProtocol = LessonController()
        let presenter: LessonPresenterProtocol & LessonInteractorOutputProtocol = LessonPresenter()
        let wireFrame: LessonWireFrameProtocol = LessonWireFrame()
        let interactor: LessonInteractorInputProtocol = LessonInteractor()
        
        if initiateOpenToday {
            controller.initiateOpenToday = true
        }

        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        presenter.quarterlyIndex = quarterlyIndex
        interactor.presenter = presenter

        return controller as! LessonController
    }
    class func createLessonModuleNav(quarterlyIndex: String, initiateOpenToday: Bool = false) -> ASNavigationController {
        let controller: LessonControllerProtocol = LessonController()
        let presenter: LessonPresenterProtocol & LessonInteractorOutputProtocol = LessonPresenter()
        let wireFrame: LessonWireFrameProtocol = LessonWireFrame()
        let interactor: LessonInteractorInputProtocol = LessonInteractor()
        
        if initiateOpenToday {
            controller.initiateOpenToday = true
        }

        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        presenter.quarterlyIndex = quarterlyIndex
        interactor.presenter = presenter

        return ASNavigationController(rootViewController: controller as! UIViewController)
    }

    func presentReadScreen(view: LessonControllerProtocol, lessonIndex: String) {
        let readScreen = ReadWireFrame.createReadModule(lessonIndex: lessonIndex)
        self.showReadScreen(view: view, readScreen: readScreen)
    }
    
    func showReadScreen(view: LessonControllerProtocol, readScreen: ReadController) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if let sourceView = view as? UIViewController {
            sourceView.show(readScreen, sender: nil)
        }
    }
}
