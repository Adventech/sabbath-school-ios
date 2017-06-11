//
//  QuarterlyWireFrame.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class QuarterlyWireFrame: QuarterlyWireFrameProtocol {
    class func createQuarterlyModule() -> ASNavigationController {
        let controller: QuarterlyControllerProtocol = QuarterlyController()
        let presenter:  QuarterlyPresenterProtocol & QuarterlyInteractorOutputProtocol = QuarterlyPresenter()
        let wireFrame:  QuarterlyWireFrameProtocol = QuarterlyWireFrame()
        let interactor: QuarterlyInteractorInputProtocol = QuarterlyInteractor()
        
        controller.presenter = presenter
        presenter.controller = controller
        presenter.wireFrame = wireFrame
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return ASNavigationController(rootViewController: controller as! UIViewController)
    }
    
    func reloadQuarterlyModule() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
        UIView.transition(with: appDelegate.window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { appDelegate.window!.rootViewController = QuarterlyWireFrame.createQuarterlyModule() },
                          completion: nil)
    }
    
    func presentLessonScreen(view: QuarterlyControllerProtocol, quarterlyIndex: String){
        let lessonScreen = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex)
        
        if let sourceView = view as? UIViewController {
            sourceView.show(lessonScreen, sender: nil)
        }
    }
    
    func presentLoginScreen(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let loginScreen = LoginWireFrame.createLoginModule()
        
        UIView.transition(with: appDelegate.window!,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { appDelegate.window!.rootViewController = loginScreen },
                          completion: nil)
    }
}
