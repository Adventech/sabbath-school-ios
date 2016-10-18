//
//  QuarterCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class CurrentQuarterCellNode: ASCellNode {
    let coverNode = ASNetworkImageNode()
    let titleNode = ASTextNode()
    let subtitleNode = ASTextNode()
    let readButton = ASButtonNode()
    private let dividerHeight: CGFloat = 60
    private let divider = ASDisplayNode()
    
    init(title: String, subtitle: String, cover: URL?) {
        super.init()
//        backgroundColor = UIColor.white
        
        // Cell divider
        divider.backgroundColor = UIColor.white
        divider.shouldRasterizeDescendants = true
        insertSubnode(divider, at: 0)
     
        titleNode.attributedText = TextStyles.currentQuarterTitleStyle(string: title)
        subtitleNode.attributedText = TextStyles.currentQuarterSubtitleStyle(string: subtitle)
        coverNode.url = cover
        
        readButton.setAttributedTitle(TextStyles.readButtonStyle(string: "Today's Lesson"), for: ASControlState())
        readButton.backgroundColor = UIColor.baseGray4
        readButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        readButton.cornerRadius = 4
        
        addSubnode(titleNode)
        addSubnode(subtitleNode)
        addSubnode(coverNode)
        addSubnode(readButton)
        
//        usesImplicitHierarchyManagement = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.preferredFrameSize = CGSize(width: 125, height: 187)
        
        let space = ASLayoutSpec()
        space.spacingAfter = 60
        
        readButton.spacingBefore = 14
        readButton.spacingAfter = 28
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [space, titleNode, subtitleNode, readButton]
        )
        vSpec.flexShrink = true
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .end,
            children: [coverNode, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
    
    override func layout() {
        divider.frame = CGRect(x: 0, y: calculatedSize.height-dividerHeight, width: calculatedSize.width, height: dividerHeight)
        super.layout()
    }
}
