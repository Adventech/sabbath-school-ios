//
//  ReadContextMenu.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-07.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ReadContextMenuView: ASDisplayNode {
    let dividerNode = ASTextNode()
    
    override init() {
        super.init()
        self.backgroundColor = .white
        dividerNode.attributedText = TextStyles.cellDetailStyle(string: "hello,world")
        automaticallyManagesSubnodes = true        
    }
    
    override func layout(){
        super.layout()
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: dividerNode)
    }
}
