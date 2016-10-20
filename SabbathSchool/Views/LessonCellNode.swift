//
//  QuarterlyCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LessonCellNode: ASCellNode {
    let titleNode = ASTextNode()
    let subtitleNode = ASTextNode()
    let numberNode = ASTextNode()
    
    // MARK: - Init
    
    init(title: String, subtitle: String, number: String) {
        super.init()
        backgroundColor = UIColor.white
     
        titleNode.attributedText = TextStyles.cellTitleStyle(string: title)
        subtitleNode.attributedText = TextStyles.cellSubtitleStyle(string: subtitle)
        numberNode.attributedText = TextStyles.cellLessonNumberStyle(string: number)
        
        usesImplicitHierarchyManagement = true
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        numberNode.spacingBefore = 6
        numberNode.preferredFrameSize = CGSize(width: 24, height: constrainedSize.max.height)
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, subtitleNode]
        )
        vSpec.flexShrink = true
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .center,
            children: [numberNode, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
}
