//
//  FeaturedQuarterlyCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ProfileUserCellNode: ASCellNode {
    let avatarNode = ASNetworkImageNode()
    let nameNode = ASTextNode()
    
    // MARK: - Init
    
    init(name: String, avatar: URL?) {
        super.init()
        
        selectionStyle = .none
        usesImplicitHierarchyManagement = true
     
        // Nodes
        nameNode.attributedText = TextStyles.profileUserNameStyle(string: name)
        
        avatarNode.url = avatar
        avatarNode.backgroundColor = UIColor.baseGray1
        avatarNode.preferredFrameSize = CGSize(width: 90, height: 90)
        avatarNode.cornerRadius = avatarNode.preferredFrameSize.width/2
        avatarNode.clipsToBounds = true
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spaceSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 12,
            justifyContent: .center,
            alignItems: .center,
            children: [avatarNode, nameNode]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 40, left: 15, bottom: 30, right: 15), child: spaceSpec)
    }
}
