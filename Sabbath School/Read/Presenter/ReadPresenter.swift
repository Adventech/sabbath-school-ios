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

class ReadPresenter: ReadPresenterProtocol {
    var controller: ReadControllerProtocol?
    var wireFrame: ReadWireFrameProtocol?
    var interactor: ReadInteractorInputProtocol?
    var lessonIndex: String?

    func configure() {
        interactor?.configure()
        interactor?.retrieveLessonInfo(lessonIndex: lessonIndex!)
    }

    func presentBibleScreen(read: Read, verse: String, size: CGSize) {

        let bibleScreen = BibleWireFrame.createBibleModule(read: read, verse: verse)
        (bibleScreen as! BibleController).delegate = (controller as! BibleControllerOutputProtocol)
        let navigation = ASNavigationController(rootViewController: bibleScreen)
        
        var attributes = EKAttributes.centerFloat
        attributes.positionConstraints.size = .init(width: EKAttributes.PositionConstraints.Edge.ratio(value: 0.9), height: EKAttributes.PositionConstraints.Edge.ratio(value: 0.8))
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)

        attributes.displayDuration = .infinity
        attributes.roundCorners = .all(radius: 6)

        // Set its background to white
        attributes.entryBackground = .color(color: EKColor(currentTheme().backgroundColor))
        attributes.screenBackground = .color(color: EKColor(UIColor(white: 0, alpha: 0.5)))
        
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))

        // Animate in and out using default translation
        attributes.entranceAnimation = .init(
            scale: .init(from: 0.6, to: 1, duration: 0.4, spring: .init(damping: 0.6, initialVelocity: 2)),
            fade: .init(from: 0.3, to: 1, duration: 0.1)
        )
        
        attributes.entryInteraction = .forward
        attributes.screenInteraction = .dismiss
        
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        SwiftEntryKit.display(entry: navigation, using: attributes)
    }

    func presentReadOptionsScreen(size: CGSize, sourceView: UIBarButtonItem) {
        let readOptionsScreen = ReadOptionsController(delegate: self.controller as! ReadOptionsDelegate)
        readOptionsScreen.modalPresentationStyle = .popover
        readOptionsScreen.modalTransitionStyle = .crossDissolve
        readOptionsScreen.preferredContentSize = size
        readOptionsScreen.popoverPresentationController?.barButtonItem = sourceView
        readOptionsScreen.popoverPresentationController?.delegate = readOptionsScreen
        readOptionsScreen.popoverPresentationController?.backgroundColor = .baseBackground
        
        (controller as! UIViewController).present(readOptionsScreen, animated: true, completion: nil)
    }
    
    func presentDictionary(word: String) {
        let referenceVC = UIReferenceLibraryViewController(term: word)
        (controller as! UIViewController).present(referenceVC, animated: true)
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
