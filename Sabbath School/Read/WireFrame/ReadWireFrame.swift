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

class ReadWireFrame: ReadWireFrameProtocol {
    class func createReadModule(lessonIndex: String) -> ASDKViewController<ASDisplayNode> {
        let controller: ReadControllerProtocol = ReadController()
        let presenter: ReadPresenterProtocol & ReadInteractorOutputProtocol = ReadPresenter()
        let wireFrame: ReadWireFrameProtocol = ReadWireFrame()
        let interactor: ReadInteractorInputProtocol = ReadInteractor()

        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        presenter.lessonIndex = lessonIndex
        interactor.presenter = presenter
        
        return controller as! ASDKViewController<ASDisplayNode>
    }

    func presentBibleScreen(view: ReadControllerProtocol, read: Read, verse: String) {
        let bibleScreen = BibleWireFrame.createBibleModule(read: read, verse: verse)

        if let sourceView = view as? UIViewController {
            sourceView.show(bibleScreen, sender: nil)
        }
    }
}
