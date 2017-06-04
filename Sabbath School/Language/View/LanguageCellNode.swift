//
//  LanguageCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit


class LanguageCellNode: ASCellNode {
    let titleNode = ASTextNode()
    let subtitleNode = ASTextNode()
    let selectedNode = ASImageNode()
    
    init(title: String, subtitle: String) {
        super.init()
        
        titleNode.attributedText = TextStyles.languageTitleStyle(string: title)
        subtitleNode.attributedText = TextStyles.languageSubtitleStyle(string: subtitle)
        selectedNode.image = R.image.iconCheckmark()?.imageTintColor(.tintColor)
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 2,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, subtitleNode]
        )
        
        var hSpecChildren: [ASLayoutElement] = [vSpec]
        if isSelected { hSpecChildren.append(selectedNode) }
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 4,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: hSpecChildren
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15), child: hSpec)
    }
}
