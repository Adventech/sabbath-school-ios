//
//  LessonPresenter.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

class LessonPresenter: LessonPresenterProtocol {
    var controller: LessonControllerProtocol?
    var wireFrame: LessonWireFrameProtocol?
    var interactor: LessonInteractorInputProtocol?
    var quarterlyIndex: String?
    
    func configure(){
        interactor?.configure()
        interactor?.retrieveQuarterlyInfo(quarterlyIndex: quarterlyIndex!)
    }
    
    func presentReadScreen(lessonIndex: String) {
        wireFrame?.presentReadScreen(view: controller!, lessonIndex: lessonIndex)
    }
}

extension LessonPresenter: LessonInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }
    
    func didRetrieveQuarterlyInfo(quarterlyInfo: QuarterlyInfo) {
        controller?.showLessons(quarterlyInfo: quarterlyInfo)
    }
}
