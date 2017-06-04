//
//  QuarterlyPresenter.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

class QuarterlyPresenter: QuarterlyPresenterProtocol {
    var controller: QuarterlyControllerProtocol?
    var wireFrame: QuarterlyWireFrameProtocol?
    var interactor: QuarterlyInteractorInputProtocol?
    
    func configure(){
        interactor?.configure()
    }
    
    func presentQuarterlies(){
        interactor?.retrieveQuarterlies()
    }
    
    func presentLanguageScreen(size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate){
        (controller as! UIViewController).present(LanguageWireFrame.createLanguageModule(size: size, transitioningDelegate: transitioningDelegate, didSelectLanguageHandler: {
            self.controller?.retrieveQuarterlies()
        }), animated: true, completion: nil)
    }
    
    func presentLessonScreen(quarterlyIndex: String){
        wireFrame?.presentLessonScreen(view: controller!, quarterlyIndex: quarterlyIndex)
    }
}

extension QuarterlyPresenter: QuarterlyInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }
    
    func didRetrieveQuarterlies(quarterlies: [Quarterly]){
        controller?.showQuarterlies(quarterlies: quarterlies)
    }
}
