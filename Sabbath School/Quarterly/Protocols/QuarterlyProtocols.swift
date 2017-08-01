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

protocol QuarterlyPresenterProtocol: class {
    var controller: QuarterlyControllerProtocol? { get set }
    var wireFrame: QuarterlyWireFrameProtocol? { get set }
    var interactor: QuarterlyInteractorInputProtocol? { get set }

    func configure()
    func presentLanguageScreen(size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate)
    func presentLessonScreen(quarterlyIndex: String)
    func presentQuarterlies()
}

protocol QuarterlyControllerProtocol: class {
    var presenter: QuarterlyPresenterProtocol? { get set }
    func showQuarterlies(quarterlies: [Quarterly])
    func retrieveQuarterlies()
}

protocol QuarterlyWireFrameProtocol: class {
    static func createQuarterlyModule() -> ASNavigationController
    func reloadQuarterlyModule()
    func presentLessonScreen(view: QuarterlyControllerProtocol, quarterlyIndex: String)
    static func presentLoginScreen()
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
