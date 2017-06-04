//
//  ReadWireFrame.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class ReadWireFrame: ReadWireFrameProtocol {
    class func createReadModule(lessonIndex: String) -> ASViewController<ASDisplayNode> {
        let controller: ReadControllerProtocol = ReadController()
        let presenter:  ReadPresenterProtocol & ReadInteractorOutputProtocol = ReadPresenter()
        let wireFrame:  ReadWireFrameProtocol = ReadWireFrame()
        let interactor: ReadInteractorInputProtocol = ReadInteractor()
        
        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        presenter.lessonIndex = lessonIndex
        interactor.presenter = presenter
        
        return controller as! ASViewController<ASDisplayNode>
    }
    
    func presentBibleScreen(view: ReadControllerProtocol, read: Read, verse: String){
        let bibleScreen = BibleWireFrame.createBibleModule(read: read, verse: verse)
        
        if let sourceView = view as? UIViewController {
            sourceView.show(bibleScreen, sender: nil)
        }
    }
}
