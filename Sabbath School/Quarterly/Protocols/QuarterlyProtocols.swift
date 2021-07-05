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

protocol QuarterlyControllerV2Protocol: class {
    var presenter: QuarterlyPresenterV2Protocol? { get set }
    var initiateOpen: Bool? { get set }
    func showQuarterlies(quarterlies: [Quarterly])
    func retrieveQuarterlies()
}

protocol QuarterlyWireFrameV2Protocol: class {
    static func createQuarterlyModule(initiateOpen: Bool) -> ASNavigationController
    static func presentLoginScreen()
    func presentLessonScreen(view: QuarterlyControllerV2Protocol, quarterlyIndex: String, initiateOpenToday: Bool)
    func showLessonScreen(view: QuarterlyControllerV2Protocol, lessonScreen: LessonController)
    func presentSingleGroupScreen(view: QuarterlyControllerV2Protocol, selectedQuarterlyGroup: QuarterlyGroup)
}

protocol QuarterlyPresenterV2Protocol: class {
    var controller: QuarterlyControllerV2Protocol? { get set }
    var wireFrame: QuarterlyWireFrameV2Protocol? { get set }
    var interactor: QuarterlyInteractorInputProtocol? { get set }

    func configure()
    func presentLanguageScreen()
    func presentGCScreen()
    func presentLessonScreen(quarterlyIndex: String, initiateOpenToday: Bool)
    func showLessonScreen(lessonScreen: LessonController)
    func presentSingleGroupScreen(selectedQuarterlyGroup: QuarterlyGroup)
    func presentQuarterlies()
}

//

protocol QuarterlyPresenterProtocol: class {
    var controller: QuarterlyControllerProtocol? { get set }
    var wireFrame: QuarterlyWireFrameProtocol? { get set }
    var interactor: QuarterlyInteractorInputProtocol? { get set }

    func configure()
    func presentLanguageScreen()
    func presentGCScreen()
    func presentLessonScreen(quarterlyIndex: String, initiateOpenToday: Bool)
    func showLessonScreen(lessonScreen: LessonController)
    func presentQuarterlies()
}

protocol QuarterlyControllerProtocol: class {
    var presenter: QuarterlyPresenterProtocol? { get set }
    var initiateOpen: Bool? { get set }
    func showQuarterlies(quarterlies: [Quarterly])
    func retrieveQuarterlies()
}

protocol QuarterlyWireFrameProtocol: class {
    static func createQuarterlyModule(initiateOpen: Bool) -> ASNavigationController
    static func presentLoginScreen()
    func presentLessonScreen(view: QuarterlyControllerProtocol, quarterlyIndex: String, initiateOpenToday: Bool)
    func showLessonScreen(view: QuarterlyControllerProtocol, lessonScreen: LessonController)
}

protocol QuarterlyInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveQuarterlies(quarterlies: [Quarterly])
}

protocol QuarterlyInteractorInputProtocol: class {
    var presenter: QuarterlyInteractorOutputProtocol? { get set }
    var languageInteractor: LanguageInteractor { get set }

    func configure()
    func retrieveQuarterlies()
    func retrieveQuarterliesForLanguage(language: QuarterlyLanguage)
}
