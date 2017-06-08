//
//  ContextMenuController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-07.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ReadContextMenuController: ASViewController<ASDisplayNode> {
    var readContextMenuView = ReadContextMenuView()
    
    init() {
        super.init(node: readContextMenuView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
