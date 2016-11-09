//
//  LanguageCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 09/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LanguageCellNode: ASCellNode {
    let titleNode = ASTextNode()
    let subtitleNode = ASTextNode()
    let selectedNode = ASImageNode()
    
    // MARK: - Init
    
    init(title: String, subtitle: String) {
        super.init()
        
        titleNode.attributedText = TextStyles.languageTitleStyle(string: title)
        subtitleNode.attributedText = TextStyles.languageSubtitleStyle(string: subtitle)
        selectedNode.image = R.image.iconCheckmark()?.imageTintColor(.tintColor)
        
        usesImplicitHierarchyManagement = true
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 2,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, subtitleNode]
        )
        
        var hSpecChildren: [ASLayoutable] = [vSpec]
        if isSelected { hSpecChildren.append(selectedNode) }
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 4,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: hSpecChildren
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15), child: hSpec)
    }
}
