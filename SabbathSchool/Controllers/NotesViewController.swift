//
//  NotesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 23/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class NotesViewController: ASViewController<ASDisplayNode> {
    
    // MARK: - Init
        
    init() {
        super.init(node: ASTableNode())
//        tableNode.delegate = self
//        tableNode.dataSource = self
        
        title = "Note".uppercased()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
}
