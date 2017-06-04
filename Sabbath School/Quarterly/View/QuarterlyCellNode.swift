//
//  QuarterlyNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class QuarterlyCellNode: ASCellNode {
    let coverNode = ASNetworkImageNode()
    let titleNode = ASTextNode()
    let humanDateNode = ASTextNode()
    let descriptionNode = ASTextNode()
    
    init(quarterly: Quarterly) {
        super.init()
        backgroundColor = UIColor.white
        
        titleNode.attributedText        = TextStyles.cellTitleStyle(string: quarterly.title)
        humanDateNode.attributedText    = TextStyles.cellSubtitleStyle(string: quarterly.humanDate)
        descriptionNode.attributedText  = TextStyles.cellDetailStyle(string: quarterly.description)
        descriptionNode.maximumNumberOfLines = 3
        coverNode.url = quarterly.cover
        coverNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
        coverNode.placeholderEnabled = true
        coverNode.placeholderFadeDuration = 0.6
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: 90, height: 135)
        descriptionNode.style.spacingBefore = 6
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, humanDateNode, descriptionNode]
        )
        
        vSpec.style.flexShrink = 1.0
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [coverNode, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
}

