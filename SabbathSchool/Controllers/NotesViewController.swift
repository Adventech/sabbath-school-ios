//
//  NotesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 23/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class NotesViewController: ASViewController<ASDisplayNode> {
    
    // MARK: - Init
        
    init() {
        super.init(node: ASTableNode())
//        tableNode.delegate = self
//        tableNode.dataSource = self
        
        title = "Notes".uppercased()
        tabBarItem.image = R.image.iconNotes()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTranslucentNavigation(true, color: .tintColor, tintColor: .white, titleColor: .white)
    }
    
    
    // MARK: - Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
