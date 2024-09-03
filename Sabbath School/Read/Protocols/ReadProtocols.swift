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

protocol ReadPresenterProtocol: AnyObject {
    var controller: ReadControllerProtocol? { get set }
    var interactor: ReadInteractorInputProtocol? { get set }
    var wireFrame: ReadWireFrameProtocol? { get set }
    var lessonIndex: String? { get set }

    func configure()
    func presentBibleScreen(read: Read, verse: String, size: CGSize)
    func presentReadOptionsScreen(size: CGSize, sourceView: UIBarButtonItem)
    func presentDictionary(word: String)
    func dismissBibleScreen()
}

protocol ReadControllerProtocol: AnyObject {
    var presenter: ReadPresenterProtocol? { get set }
    var readIndex: Int? { get set }

    func loadLessonInfo(lessonInfo: LessonInfo)
    func showRead(read: Read, finish: Bool)
    func loadAudio(audio: [Audio])
    func loadVideo(video: [VideoInfo])
    func setHighlights(highlights: ReadHighlights)
    func setComments(comments: ReadComments)
    func setPublishingInfo(publishingInfo: PublishingInfo?)
}

protocol ReadControllerDelegate: AnyObject {
    func shareLesson(lesson: Lesson)
}

protocol ReadWireFrameProtocol: AnyObject {
    static func createReadModule(lessonIndex: String, readIndex: Int?) -> ReadController
}

protocol ReadInteractorOutputProtocol: AnyObject {
    func onError(_ error: Error?)
    func didRetrieveRead(read: Read, ticker: Int)
    func didRetrieveLessonInfo(lessonInfo: LessonInfo)
    func didRetrieveAudio(audio: [Audio])
    func didRetrieveVideo(video: [VideoInfo])
    func didRetrieveHighlights(highlights: ReadHighlights)
    func didRetrieveComments(comments: ReadComments)
    func didRetrievePublishingInfo(publishingInfo: PublishingInfo?)
}

protocol ReadInteractorInputProtocol: AnyObject {
    var presenter: ReadInteractorOutputProtocol? { get set }
    var quarterlyDownloadDelegate: DownloadQuarterlyDelegate? { get set }

    func retrieveRead(readIndex: String, quarterlyIndex: String?)
    func retrieveLessonInfo(lessonIndex: String, quarterlyIndex: String?)
    func retrieveHighlights(readIndex: String)
    func retrieveAudio(quarterlyIndex: String)
    func saveHighlights(highlights: ReadHighlights)
    func saveComments(comments: ReadComments)
    func retrievePublishingInfo()
}
