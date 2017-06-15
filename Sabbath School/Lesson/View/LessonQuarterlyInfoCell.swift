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
    let coverNode = ASDisplayNode()
    var coverImageNode: RoundedCornersImage!
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
        titleNode.attributedText = TextStyles.lessonInfoTitleStyle(string: quarterly.title)
        humanDateNode.attributedText = TextStyles.lessonInfoHumanDateStyle(string: quarterly.humanDate.uppercased())
        detailNode.attributedText = TextStyles.cellDetailStyle(string: quarterly.description, color: .white)
        detailNode.maximumNumberOfLines = 8
        
        readButton.setAttributedTitle(TextStyles.readButtonStyle(string: "Read".uppercased()), for: UIControlState())
        readButton.backgroundColor = UIColor.init(hex: (quarterly.colorPrimaryDark)!)
        readButton.contentEdgeInsets = ButtonStyle.openButtonUIEdgeInsets()
        readButton.cornerRadius = 18
        
        coverNode.cornerRadius = 4
        coverNode.shadowColor = UIColor.baseGray2.cgColor
        coverNode.shadowOffset = CGSize(width: 0, height: 2)
        coverNode.shadowRadius = 3
        coverNode.shadowOpacity = 0.6
        coverNode.clipsToBounds = true        
        
        coverImageNode = RoundedCornersImage(imageURL: quarterly.cover, corner: coverNode.cornerRadius)
        coverImageNode.style.alignSelf = .stretch
        
        addSubnode(titleNode)
        addSubnode(humanDateNode)
        addSubnode(detailNode)
        addSubnode(coverNode)
        addSubnode(coverImageNode)
        addSubnode(readButton)
    }
    
    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: 130, height: 192)
        titleNode.style.spacingAfter = 20
        readButton.style.spacingBefore = 10
        humanDateNode.style.spacingAfter = 6
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [humanDateNode, titleNode]
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
        
        let coverSpec = ASBackgroundLayoutSpec(child: coverImageNode, background: coverNode)
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .center,
            alignItems: .center,
            children: [coverSpec, vSpec2]
        )
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [vSpec, hSpec]
        )
    
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 30, right: 15), child: mainSpec)
    }
    
    override func layout() {
        super.layout()
        infiniteColor.frame = CGRect(x: 0, y: calculatedSize.height-1000, width: calculatedSize.width, height: 1000)
    }
}
