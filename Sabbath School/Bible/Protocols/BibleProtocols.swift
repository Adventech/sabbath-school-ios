//
//  BibleProtocols.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol BiblePresenterProtocol: class {
    var controller: BibleControllerProtocol? { get set }
    var interactor: BibleInteractorInputProtocol? { get set }
    var wireFrame: BibleWireFrameProtocol? { get set }
    
    func configure()
    func presentBibleVerse(read: Read, verse: String)
}

protocol BibleControllerProtocol: class {
    var presenter: BiblePresenterProtocol? { get set }
    
    func showBibleVerse(content: String)
}

protocol BibleControllerOutputProtocol: class {
    func didDismissBibleScreen()
}

protocol BibleWireFrameProtocol: class {
    static func createBibleModule(read: Read, verse: String) -> ASViewController<ASDisplayNode>
}

protocol BibleInteractorOutputProtocol: class {
    func onError(_ error: Error?)
    func didRetrieveBibleVerse(content: String)
}

protocol BibleInteractorInputProtocol: class {
    var presenter: BibleInteractorOutputProtocol? { get set }
    
    func configure()
    func retrieveBibleVerse(read: Read, verse: String)
    func preferredBibleVersionFor(bibleVerses: [BibleVerses]) -> String?
}
