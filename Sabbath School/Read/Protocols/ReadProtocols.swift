//
//  ReadProtocols.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol ReadPresenterProtocol: class {
    var controller: ReadControllerProtocol? { get set }
    var interactor: ReadInteractorInputProtocol? { get set }
    var wireFrame: ReadWireFrameProtocol? { get set }
    var lessonIndex: String? { get set }
    
    func configure()
    func presentBibleScreen(read: Read, verse: String, size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate)
    func presentReadOptionsScreen(size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate)
}

protocol ReadControllerProtocol: class {
    var presenter: ReadPresenterProtocol? { get set }
    
    func loadLessonInfo(lessonInfo: LessonInfo)
    func showRead(read: Read, highlights: ReadHighlights, comments: ReadComments)
}

protocol ReadWireFrameProtocol: class {
    static func createReadModule(lessonIndex: String) -> ASViewController<ASDisplayNode>
}

protocol ReadInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveRead(read: Read, highlights: ReadHighlights, comments: ReadComments)
    func didRetrieveLessonInfo(lessonInfo: LessonInfo)
}

protocol ReadInteractorInputProtocol: class {
    var presenter: ReadInteractorOutputProtocol? { get set }
    
    func configure()
    func retrieveRead(readIndex: String)
    func retrieveLessonInfo(lessonIndex: String)
    func retrieveHighlights(read: Read)
    func saveHighlights(read: Read, highlights: String)
    func saveComments(comments: ReadComments)
}
