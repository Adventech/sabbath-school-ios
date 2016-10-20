//
//  QuarterCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class QuarterCellNode: ASCellNode {
    let coverNode = ASNetworkImageNode()
    let titleNode = ASTextNode()
    let subtitleNode = ASTextNode()
    let detailNode = ASTextNode()
    
    // MARK: - Init
    
    init(title: String, subtitle: String, detail: String, cover: URL?) {
        super.init()
        backgroundColor = UIColor.white
     
        titleNode.attributedText = TextStyles.cellTitleStyle(string: title)
        subtitleNode.attributedText = TextStyles.cellSubtitleStyle(string: subtitle)
        detailNode.attributedText = TextStyles.cellDetailStyle(string: detail)
        detailNode.maximumNumberOfLines = 2
        coverNode.url = cover
        
        usesImplicitHierarchyManagement = true
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.preferredFrameSize = CGSize(width: 90, height: 135)
        detailNode.spacingBefore = 6
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, subtitleNode, detailNode]
        )
        vSpec.flexShrink = true
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: .center,
            children: [coverNode, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
}
