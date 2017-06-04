//
//  BibleWireFrame.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class BibleWireFrame: BibleWireFrameProtocol {
    class func createBibleModule(read: Read, verse: String) -> ASViewController<ASDisplayNode> {
        let controller: BibleControllerProtocol = BibleController(read: read, verse: verse)
        let presenter:  BiblePresenterProtocol & BibleInteractorOutputProtocol = BiblePresenter()
        let wireFrame:  BibleWireFrameProtocol = BibleWireFrame()
        let interactor: BibleInteractorInputProtocol = BibleInteractor()
        
        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return controller as! ASViewController<ASDisplayNode>
    }
}
