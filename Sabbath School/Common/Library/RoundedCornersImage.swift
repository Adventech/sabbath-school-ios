//
//  RoundedCornersImage.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-14.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

final class RoundedCornersImage: ASDisplayNode {    
    var imageNode = ASNetworkImageNode()
    
    init(imageURL: URL, corner: CGFloat) {
        super.init()
        
        imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
        imageNode.placeholderEnabled = true
        imageNode.placeholderFadeDuration = 0.6
        
        cornerRadius = corner
        clipsToBounds = true
        
        imageNode.url = imageURL
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.preferredSize = CGSize(width: 125, height: 187)
        return ASAbsoluteLayoutSpec(children: [imageNode])
    }
}
