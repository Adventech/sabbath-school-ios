//
//  LessonProtocol.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol LessonPresenterProtocol: class {
    var controller: LessonControllerProtocol? { get set }
    var interactor: LessonInteractorInputProtocol? { get set }
    var wireFrame: LessonWireFrameProtocol? { get set }
    var quarterlyIndex: String? { get set }
    
    func configure()
    func presentReadScreen(lessonIndex: String)
}

protocol LessonControllerProtocol: class {
    var presenter: LessonPresenterProtocol? { get set }
    func showLessons(quarterlyInfo: QuarterlyInfo)
}

protocol LessonWireFrameProtocol: class {
    static func createLessonModule(quarterlyIndex: String) -> ASViewController<ASDisplayNode>
    func presentReadScreen(view: LessonControllerProtocol, lessonIndex: String)
}

protocol LessonInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveQuarterlyInfo(quarterlyInfo: QuarterlyInfo)
}

protocol LessonInteractorInputProtocol: class {
    var presenter: LessonInteractorOutputProtocol? { get set }
    
    func configure()
    func retrieveQuarterlyInfo(quarterlyIndex: String)
}
