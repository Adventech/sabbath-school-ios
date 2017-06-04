//
//  ReadOptionsController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ReadOptionsController: ASViewController<ASDisplayNode> {
    var readOptionsView = ReadOptionsView()
    
    init() {
        super.init(node: readOptionsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
