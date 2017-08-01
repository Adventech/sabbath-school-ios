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

protocol BiblePresenterProtocol: class {
    var controller: BibleControllerProtocol? { get set }
    var interactor: BibleInteractorInputProtocol? { get set }
    var wireFrame: BibleWireFrameProtocol? { get set }

    func configure()
    func presentBibleVerse(read: Read, verse: String)
}

protocol BibleControllerProtocol: class {
    var presenter: BiblePresenterProtocol? { get set }

    func showBibleVerse(content: String)
}

protocol BibleControllerOutputProtocol: class {
    func didDismissBibleScreen()
}

protocol BibleWireFrameProtocol: class {
    static func createBibleModule(read: Read, verse: String) -> ASViewController<ASDisplayNode>
}

protocol BibleInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveBibleVerse(content: String)
}

protocol BibleInteractorInputProtocol: class {
    var presenter: BibleInteractorOutputProtocol? { get set }

    func configure()
    func retrieveBibleVerse(read: Read, verse: String)
    func preferredBibleVersionFor(bibleVerses: [BibleVerses]) -> String?
}
