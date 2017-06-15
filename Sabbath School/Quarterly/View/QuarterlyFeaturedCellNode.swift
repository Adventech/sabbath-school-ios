//
//  QuarterlyFeaturedCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class QuarterlyFeaturedCellNode: ASCellNode {
    let coverNode = ASNetworkImageNode()
    var coverImageNode: RoundedCornersImage!
    let titleNode = ASTextNode()
    let humanDateNode = ASTextNode()
    let descriptionNode = ASTextNode()
    let openButton = OpenButton()
    
    private let infiniteColor = ASDisplayNode()
    
    init(quarterly: Quarterly) {
        super.init()
        
        if let color = quarterly.colorPrimary {
            backgroundColor = UIColor.init(hex: color)
        } else {
            backgroundColor = UIColor.baseGreen
        }
        
        clipsToBounds = false
        insertSubnode(infiniteColor, at: 0)
        selectionStyle = .none
        
        titleNode.attributedText = TextStyles.featuredQuarterlyTitleStyle(string: quarterly.title)
        titleNode.maximumNumberOfLines = 3
        titleNode.pointSizeScaleFactors = [0.9, 0.8]
        
        humanDateNode.attributedText = TextStyles.featuredQuarterlyHumanDateStyle(string: quarterly.humanDate)
        humanDateNode.maximumNumberOfLines = 1
        
        descriptionNode.attributedText = TextStyles.featuredQuarterlyDescriptionStyle(string: quarterly.description)
        descriptionNode.maximumNumberOfLines = 3
        
        coverNode.cornerRadius = 4
        coverNode.clipsToBounds = true
        
        coverImageNode = RoundedCornersImage(imageURL: quarterly.cover, corner: coverNode.cornerRadius)
        coverImageNode.style.alignSelf = .stretch
        
        openButton.setAttributedTitle(TextStyles.readButtonStyle(string: "Open".uppercased()), for: UIControlState())
        openButton.backgroundColor = UIColor.init(hex: (quarterly.colorPrimaryDark)!)
        openButton.contentEdgeInsets = ButtonStyle.openButtonUIEdgeInsets()
        openButton.cornerRadius = 18
        
        addSubnode(titleNode)
        addSubnode(humanDateNode)
        addSubnode(descriptionNode)
        addSubnode(coverNode)
        addSubnode(coverImageNode)
        addSubnode(openButton)
    }
    
    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: 125, height: 187)
        openButton.style.spacingBefore = 10
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [humanDateNode, titleNode, openButton]
        )
        
        vSpec.style.flexShrink = 1.0
        
        let coverSpec = ASBackgroundLayoutSpec(child: coverImageNode, background: coverNode)
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .center,
            children: [coverSpec, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 20, right: 15), child: hSpec)
    }
    
    override func layout() {
        super.layout()
        infiniteColor.frame = CGRect(x: 0, y: calculatedSize.height-1000, width: calculatedSize.width, height: 1000)
    }
}
