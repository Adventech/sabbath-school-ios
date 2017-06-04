//
//  BibleVersionView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class BibleVersionView: ASCellNode {
    let titleNode = ASTextNode()
    let selectedNode = ASImageNode()
    
    init(title: String, isSelected: Bool) {
        super.init()
        
        self.isSelected = isSelected
        
        titleNode.attributedText = TextStyles.languageTitleStyle(string: title)
        selectedNode.image = R.image.iconCheckmark()?.imageTintColor(.tintColor)
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 2,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode]
        )
        
        var hSpecChildren: [ASLayoutElement] = [vSpec]
        
        if isSelected { hSpecChildren.append(selectedNode) }
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: hSpecChildren
        )
        
        hSpec.style.alignSelf = .stretch
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15), child: hSpec)
    }
}
