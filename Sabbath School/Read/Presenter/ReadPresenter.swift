//
//  ReadPresenter.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ReadPresenter: ReadPresenterProtocol {
    var controller: ReadControllerProtocol?
    var wireFrame: ReadWireFrameProtocol?
    var interactor: ReadInteractorInputProtocol?
    var lessonIndex: String?
    
    func configure(){
        interactor?.configure()
        interactor?.retrieveLessonInfo(lessonIndex: lessonIndex!)
    }
    
    func presentBibleScreen(read: Read, verse: String, size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate){
        
        let bibleScreen = BibleWireFrame.createBibleModule(read: read, verse: verse)
        (bibleScreen as! BibleController).delegate = (controller as! BibleControllerOutputProtocol)
        let navigation = ASNavigationController(rootViewController: bibleScreen)
        navigation.transitioningDelegate = transitioningDelegate
        navigation.modalPresentationStyle = .custom
        navigation.preferredContentSize = size
        (controller as! UIViewController).present(navigation, animated: true, completion: nil)        
    }
    
    func presentReadOptionsScreen(size: CGSize, transitioningDelegate: UIViewControllerTransitioningDelegate){
        let readOptionsScreen = ReadOptionsController(delegate: self.controller as! ReadOptionsDelegate)
        readOptionsScreen.transitioningDelegate = transitioningDelegate
        readOptionsScreen.modalPresentationStyle = .custom
        readOptionsScreen.preferredContentSize = size
        (controller as! UIViewController).present(readOptionsScreen, animated: true, completion: nil)
    }
}

extension ReadPresenter: ReadInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }
    
    func didRetrieveRead(read: Read, highlights: ReadHighlights, comments: ReadComments){
        controller?.showRead(read: read, highlights: highlights, comments: comments)
    }
    
    func didRetrieveLessonInfo(lessonInfo: LessonInfo) {
        controller?.loadLessonInfo(lessonInfo: lessonInfo)
    }
}
