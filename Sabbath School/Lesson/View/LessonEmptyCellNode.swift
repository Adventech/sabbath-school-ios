//
//  LessonEmptyCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-02.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

final class LessonEmptyCellNode: ASCellNode {
    let titleEmptyNode = ASDisplayNode()
    let humanDateEmptyNode = ASDisplayNode()
    
    let divider = ASDisplayNode()
    var dividerHeight: CGFloat = 1
    
    override init() {
        super.init()
        
        titleEmptyNode.backgroundColor = UIColor.baseGray1
        humanDateEmptyNode.backgroundColor = UIColor.baseGray1
        
        // Cell divider
        divider.backgroundColor = UIColor.baseGray1
        
        addSubnode(divider)
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width*0.56, height: 18)
        humanDateEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width*0.14, height: 10)
        humanDateEmptyNode.style.spacingBefore = 8
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleEmptyNode, humanDateEmptyNode]
        )
        
        vSpec.style.flexShrink = 1.0
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: vSpec)
    }
    
    override func layout() {
        super.layout()
        divider.frame = CGRect(x: 0, y: calculatedSize.height-dividerHeight, width: calculatedSize.width, height: dividerHeight)
        
        addShimmerToNode(node: titleEmptyNode)
        addShimmerToNode(node: humanDateEmptyNode)
    }
}
