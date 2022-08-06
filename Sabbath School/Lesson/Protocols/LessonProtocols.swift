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

protocol LessonPresenterProtocol: AnyObject {
    var controller: LessonControllerProtocol? { get set }
    var interactor: LessonInteractorInputProtocol? { get set }
    var wireFrame: LessonWireFrameProtocol? { get set }
    var quarterlyIndex: String? { get set }

    func configure()
    func presentReadScreen(lessonIndex: String)
    func showReadScreen(readScreen: ReadController)
}

protocol LessonControllerProtocol: AnyObject {
    var presenter: LessonPresenterProtocol? { get set }
    var initiateOpenToday: Bool? { get set }
    func showLessons(quarterlyInfo: QuarterlyInfo)
    func showPublishingInfo(publishingInfo: PublishingInfo?)
}

protocol LessonControllerDelegate: AnyObject {
    func shareQuarterly(quarterly: Quarterly)
}

protocol LessonWireFrameProtocol: AnyObject {
    static func createLessonModule(quarterlyIndex: String, initiateOpenToday: Bool) -> LessonController
    static func createLessonModuleNav(quarterlyIndex: String, initiateOpenToday: Bool) -> ASNavigationController
    func presentReadScreen(view: LessonControllerProtocol, lessonIndex: String)
    func showReadScreen(view: LessonControllerProtocol, readScreen: ReadController)
}

protocol LessonInteractorOutputProtocol: AnyObject {
    func onError(_ error: Error?)
    func didRetrieveQuarterlyInfo(quarterlyInfo: QuarterlyInfo)
    func didRetrievePublishingInfo(publishingInfo: PublishingInfo?)
}

protocol LessonInteractorInputProtocol: AnyObject {
    var presenter: LessonInteractorOutputProtocol? { get set }

    func configure()
    func retrieveQuarterlyInfo(quarterlyIndex: String)
    func retrievePublishingInfo()
}
