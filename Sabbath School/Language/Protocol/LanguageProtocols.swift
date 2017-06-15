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

protocol LanguagePresenterProtocol: class {
    var controller: LanguageControllerProtocol? { get set }
    var interactor: LanguageInteractorInputProtocol? { get set }
    var wireFrame: LanguageWireFrameProtocol? { get set }
    var didSelectLanguageHandler: ()-> Void? { get set }
    
    func configure()
}

protocol LanguageControllerProtocol: class {
    var presenter: LanguagePresenterProtocol & LanguageInteractorOutputProtocol { get set }
    func showLanguages(languages: [QuarterlyLanguage])
}

protocol LanguageWireFrameProtocol: class {
    static func createLanguageModule(size: CGSize?, transitioningDelegate: UIViewControllerTransitioningDelegate?, didSelectLanguageHandler: @escaping ()-> Void?) -> ASNavigationController
}

protocol LanguageInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveLanguages(languages: [QuarterlyLanguage])
    func didSelectLanguage(language: QuarterlyLanguage)
}

protocol LanguageInteractorInputProtocol: class {
    var presenter: LanguageInteractorOutputProtocol? { get set }
    
    func configure()
    func retrieveLanguages()
    func saveLanguage(language: QuarterlyLanguage)
}
