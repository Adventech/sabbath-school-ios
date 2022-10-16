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

class ReadReferenceVC: UIReferenceLibraryViewController {
    var tintColor: UIColor?
    
    override init(term: String) {
        super.init(term: term)
        if let tintColor = Configuration.window!.tintColor {
            self.tintColor = tintColor
            Configuration.window!.tintColor = AppStyle.Read.Color.tint
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.tintColor != nil {
            Configuration.window!.tintColor = self.tintColor
        }
    }
}

class ReadPresenter: ReadPresenterProtocol {
    var controller: ReadControllerProtocol?
    var wireFrame: ReadWireFrameProtocol?
    var interactor: ReadInteractorInputProtocol?
    var lessonIndex: String?

    func configure() {
        interactor?.configure()
        interactor?.retrieveLessonInfo(lessonIndex: lessonIndex!)
        interactor?.retrievePublishingInfo()
    }

    func presentBibleScreen(read: Read, verse: String, size: CGSize) {
        let bibleScreen = BibleWireFrame.createBibleModule(bibleVerses: read.bible, verse: verse)
        bibleScreen.delegate = (controller as! BibleControllerOutputProtocol)
        let navigation = ASNavigationController(rootViewController: bibleScreen)
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let statusBar: EKAttributes.StatusBar = (controller as! ReadController).preferredStatusBarStyle == .lightContent ? .light : .dark
        
        SwiftEntryKit.display(entry: navigation, using: Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: Preferences.currentTheme().backgroundColor, statusBar: statusBar))
    }
    
    func dismissBibleScreen() {
        SwiftEntryKit.dismiss()
    }

    func presentReadOptionsScreen(size: CGSize, sourceView: UIBarButtonItem) {
        let readOptionsScreen = ReadOptionsController(delegate: self.controller as! ReadOptionsDelegate)
        readOptionsScreen.modalPresentationStyle = .popover
        readOptionsScreen.modalTransitionStyle = .crossDissolve
        readOptionsScreen.preferredContentSize = size
        readOptionsScreen.popoverPresentationController?.barButtonItem = sourceView
        readOptionsScreen.popoverPresentationController?.delegate = readOptionsScreen
        readOptionsScreen.popoverPresentationController?.backgroundColor = AppStyle.Base.Color.background
        
        (controller as! UIViewController).present(readOptionsScreen, animated: true, completion: nil)
    }
    
    func presentDictionary(word: String) {
        let referenceVC = ReadReferenceVC(term: word)
        (controller as! UIViewController).present(referenceVC, animated: true)
    }
}

extension ReadPresenter: ReadInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print("SSDEBUG", error?.localizedDescription ?? "Unknown")
    }

    func didRetrieveRead(read: Read, ticker: Int = 0) {
        controller?.showRead(read: read, finish: ticker <= 0)
    }

    func didRetrieveLessonInfo(lessonInfo: LessonInfo) {
        controller?.loadLessonInfo(lessonInfo: lessonInfo)
    }
    
    func didRetrieveAudio(audio: [Audio]) {
        controller?.loadAudio(audio: audio)
    }
    
    func didRetrieveVideo(video: [VideoInfo]) {
        controller?.loadVideo(video: video)
    }
    
    func didRetrieveHighlights(highlights: ReadHighlights) {
        controller?.setHighlights(highlights: highlights)
    }
    
    func didRetrieveComments(comments: ReadComments) {
        controller?.setComments(comments: comments)
    }
    
    func didRetrievePublishingInfo(publishingInfo: PublishingInfo?) {
        controller?.setPublishingInfo(publishingInfo: publishingInfo)
    }
}
