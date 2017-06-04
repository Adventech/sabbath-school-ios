//
//  BiblePresenter.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

class BiblePresenter: BiblePresenterProtocol {
    var controller: BibleControllerProtocol?
    var wireFrame: BibleWireFrameProtocol?
    var interactor: BibleInteractorInputProtocol?
    
    func configure(){
        interactor?.configure()
    }
    
    func presentBibleVerse(read: Read, verse: String){
        interactor?.retrieveBibleVerse(read: read, verse: verse)
    }
}

extension BiblePresenter: BibleInteractorOutputProtocol {
    func onError(_ error: Error?) {
        print(error?.localizedDescription ?? "Unknown")
    }
    
    func didRetrieveBibleVerse(content: String){
        controller?.showBibleVerse(content: content)
    }
}
