//
//  LessonWireFrame.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class LessonWireFrame: LessonWireFrameProtocol {
    class func createLessonModule(quarterlyIndex: String) -> ASViewController<ASDisplayNode> {
        let controller: LessonControllerProtocol = LessonController()
        let presenter:  LessonPresenterProtocol & LessonInteractorOutputProtocol = LessonPresenter()
        let wireFrame:  LessonWireFrameProtocol = LessonWireFrame()
        let interactor: LessonInteractorInputProtocol = LessonInteractor()
        
        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        presenter.quarterlyIndex = quarterlyIndex
        interactor.presenter = presenter
        
        return controller as! ASViewController<ASDisplayNode>
    }
    
    func presentReadScreen(view: LessonControllerProtocol, lessonIndex: String){
        let readScreen = ReadWireFrame.createReadModule(lessonIndex: lessonIndex)
        
        if let sourceView = view as? UIViewController {
            sourceView.show(readScreen, sender: nil)
        }
    }
}
