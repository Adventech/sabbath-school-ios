//
//  LessonQuarterlyInfoCell.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LessonQuarterlyInfoNode: ASCellNode {
    let coverNode = ASNetworkImageNode()
    let titleNode = ASTextNode()
    let humanDateNode = ASTextNode()
    var detailNode = ASTextNode()
    let readButton = OpenButton()
    
    private let infiniteColor = ASDisplayNode()
    
    init(quarterly: Quarterly) {
        super.init()
        
        clipsToBounds = false
        insertSubnode(infiniteColor, at: 0)
        selectionStyle = .none
        
        if let color = quarterly.colorPrimary {
            backgroundColor = UIColor.init(hex: color)
        } else {
            backgroundColor = .baseGreen
        }
        
        // Nodes
        titleNode.attributedText = TextStyles.featuredQuarterlyTitleStyle(string: quarterly.title)
        humanDateNode.attributedText = TextStyles.featuredQuarterlyHumanDateStyle(string: quarterly.humanDate)
        detailNode.attributedText = TextStyles.cellDetailStyle(string: quarterly.description, color: .white)
        detailNode.maximumNumberOfLines = 7
        coverNode.url = quarterly.cover
        coverNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
        coverNode.placeholderEnabled = true
        coverNode.placeholderFadeDuration = 0.6
        
        readButton.setAttributedTitle(TextStyles.readButtonStyle(string: "Read".uppercased()), for: UIControlState())
        readButton.backgroundColor = UIColor.init(hex: (quarterly.colorPrimaryDark)!)
        readButton.contentEdgeInsets = ButtonStyle.openButtonUIEdgeInsets()
        readButton.cornerRadius = 4
        
        addSubnode(titleNode)
        addSubnode(humanDateNode)
        addSubnode(detailNode)
        addSubnode(coverNode)
        addSubnode(readButton)
    }
    
    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: 125, height: 187)
        readButton.style.spacingBefore = 10
        readButton.style.spacingAfter = 13
        humanDateNode.style.spacingAfter = 6
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, humanDateNode]
        )
        
        let vSpec2 = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [detailNode, readButton]
        )
        
        
        vSpec.style.flexShrink = 1.0
        vSpec2.style.flexShrink = 1.0
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .start,
            children: [coverNode, vSpec2]
        )
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [vSpec, hSpec]
        )
    
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 20, right: 15), child: mainSpec)
    }
    
    override func layout() {
        super.layout()
        infiniteColor.frame = CGRect(x: 0, y: calculatedSize.height-1000, width: calculatedSize.width, height: 1000)
    }
}
