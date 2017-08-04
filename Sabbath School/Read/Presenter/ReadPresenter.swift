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

class ReadPresenter: ReadPresenterProtocol {
    var controller: ReadControllerProtocol?
    var wireFrame: ReadWireFrameProtocol?
    var interactor: ReadInteractorInputProtocol?
    var lessonIndex: String?

    func configure() {
        interactor?.configure()
        interactor?.retrieveLessonInfo(lessonIndex: lessonIndex!)
    }

    func presentBibleScreen(read: Read, verse: String, size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate) {

        let bibleScreen = BibleWireFrame.createBibleModule(read: read, verse: verse)
        (bibleScreen as! BibleController).delegate = (controller as! BibleControllerOutputProtocol)
        let navigation = ASNavigationController(rootViewController: bibleScreen)
        navigation.transitioningDelegate = transitioningDelegate
        navigation.modalPresentationStyle = .custom
        navigation.preferredContentSize = size
        (controller as! UIViewController).present(navigation, animated: true, completion: nil)
    }

    func presentReadOptionsScreen(size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate) {
        let readOptionsScreen = ReadOptionsController(delegate: self.controller as! ReadOptionsDelegate)
        readOptionsScreen.transitioningDelegate = transitioningDelegate
        readOptionsScreen.modalPresentationStyle = .custom
        readOptionsScreen.preferredContentSize = size
        (controller as! UIViewController).present(readOptionsScreen, animated: true, completion: nil)
    }
}

extension ReadPresenter: ReadInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }

    func didRetrieveRead(read: Read, highlights: ReadHighlights, comments: ReadComments, ticker: Int = 0) {
        controller?.showRead(read: read, highlights: highlights, comments: comments, finish: ticker == 0)
    }

    func didRetrieveLessonInfo(lessonInfo: LessonInfo) {
        controller?.loadLessonInfo(lessonInfo: lessonInfo)
    }
}
