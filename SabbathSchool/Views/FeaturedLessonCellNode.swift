//
//  FeaturedQuarterlyCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FeaturedLessonCellNode: ASCellNode {
    let coverNode = ASNetworkImageNode()
    let titleNode = ASTextNode()
    let subtitleNode = ASTextNode()
    var detailNode = ASTextNode()
    let readButton = ASButtonNode()
    
    private let whiteSpace = ASDisplayNode()
    private let infiniteColor = ASDisplayNode()
    
    // MARK: - Init
    
    init(title: String, subtitle: String, detail: String, cover: URL?) {
        super.init()
        
        clipsToBounds = false
        insertSubnode(infiniteColor, at: 0)
        selectionStyle = .none
        
        whiteSpace.backgroundColor = UIColor.white
        whiteSpace.shouldRasterizeDescendants = true
        insertSubnode(whiteSpace, at: 1)
     
        // Nodes
        titleNode.attributedText = TextStyles.currentQuarterTitleStyle(string: title)
        subtitleNode.attributedText = TextStyles.currentQuarterSubtitleStyle(string: subtitle)
        detailNode.attributedText = TextStyles.cellDetailStyle(string: detail, color: .white)
        detailNode.maximumNumberOfLines = 4
        coverNode.url = cover
        
        readButton.setAttributedTitle(TextStyles.readButtonStyle(string: "Today's Lesson"), for: ASControlState())
        readButton.backgroundColor = UIColor.baseGray4
        readButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        readButton.cornerRadius = 4
        
        addSubnode(titleNode)
        addSubnode(subtitleNode)
        addSubnode(detailNode)
        addSubnode(coverNode)
        addSubnode(readButton)
    }
    
    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.preferredFrameSize = CGSize(width: 125, height: 187)
        readButton.spacingBefore = 10
        readButton.spacingAfter = 13
        subtitleNode.spacingAfter = 6
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, subtitleNode, detailNode, readButton]
        )
        vSpec.flexShrink = true
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .end,
            children: [coverNode, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 100, left: 15, bottom: 20, right: 15), child: hSpec)
    }
    
    override func layout() {
        super.layout()
        whiteSpace.frame = CGRect(x: 0, y: calculatedSize.height-50, width: calculatedSize.width, height: 50)
        infiniteColor.frame = CGRect(x: 0, y: calculatedSize.height-1000, width: calculatedSize.width, height: 1000)
    }
}
