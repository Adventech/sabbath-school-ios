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

import UIKit

class LessonPresenter: LessonPresenterProtocol {
    var controller: LessonControllerProtocol?
    var wireFrame: LessonWireFrameProtocol?
    var interactor: LessonInteractorInputProtocol?
    var quarterlyIndex: String?

    func configure() {
        interactor?.configure()
        interactor?.retrieveQuarterlyInfo(quarterlyIndex: quarterlyIndex!, completion: { _ in })
        interactor?.retrievePublishingInfo()
    }

    func presentReadScreen(lessonIndex: String) {
        wireFrame?.presentReadScreen(view: controller!, lessonIndex: lessonIndex)
    }
    
    func showReadScreen(readScreen: ReadController) {
        wireFrame?.showReadScreen(view: controller!, readScreen: readScreen)
    }
}

extension LessonPresenter: LessonInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }

    func didRetrieveQuarterlyInfo(quarterlyInfo: QuarterlyInfo) {
        controller?.showLessons(quarterlyInfo: quarterlyInfo)
    }
    
    func didRetrievePublishingInfo(publishingInfo: PublishingInfo?) {
        controller?.showPublishingInfo(publishingInfo: publishingInfo)
    }
}
