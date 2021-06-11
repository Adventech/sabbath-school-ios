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
import UIKit
import SwiftEntryKit

class QuarterlyPresenter: QuarterlyPresenterProtocol {
    weak var controller: QuarterlyControllerProtocol?
    var wireFrame: QuarterlyWireFrameProtocol?
    var interactor: QuarterlyInteractorInputProtocol?

    func configure() {
        interactor?.configure()
    }

    func presentQuarterlies() {
        interactor?.retrieveQuarterlies()
    }

    func presentLanguageScreen() {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        let module = LanguageWireFrame.createLanguageModule() { [weak self] () -> Void? in
            self?.controller?.retrieveQuarterlies()
        }

        (controller as? UIViewController)?.present(module, animated: true)
    }

    func presentLessonScreen(quarterlyIndex: String, initiateOpenToday: Bool = false) {
        wireFrame?.presentLessonScreen(view: controller!, quarterlyIndex: quarterlyIndex, initiateOpenToday: initiateOpenToday)
    }
    
    func showLessonScreen(lessonScreen: LessonController) {
        wireFrame?.showLessonScreen(view: controller!, lessonScreen: lessonScreen)
    }
    
    func presentGCScreen() {
        let gcPopupController = GCPopupController()
        let width: CGFloat = Helper.isPad ? 0.6 : 0.9
        let height: CGFloat = Helper.isPad ? 0.5 : 0.8
        
        SwiftEntryKit.display(entry: gcPopupController, using: Animation.modalAnimationAttributes(widthRatio: width, heightRatio: height))
    }
}

extension QuarterlyPresenter: QuarterlyInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }

    func didRetrieveQuarterlies(quarterlies: [Quarterly]) {
        if Preferences.currentLanguage().code == quarterlies.first?.lang {
            controller?.showQuarterlies(quarterlies: quarterlies)
        }
    }
}
