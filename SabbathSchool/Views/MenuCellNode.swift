//
//  MenuCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 02/12/16.
//  Copyright © 2016 Adventech. All rights reserved.
//


import UIKit
import AsyncDisplayKit

class MenuCellNode: ASCellNode {
    let titleNode = ASTextNode()
    var subtileNode: ASTextNode?
    var imageNode: ASImageNode?
    
    init(withTitle title: String, subtitle: String? = nil, icon: UIImage? = nil, iconSize: CGSize = CGSize(width: 20, height: 20), active: Bool = false, destructive: Bool = false) {
        super.init()
        
        backgroundColor = UIColor.white
        
        var titleStyle: NSAttributedString {
            if active {
                return TextStyles.menuTitleStyle(string: title, color: .tintColor)
            }
            
            if destructive {
                return TextStyles.menuTitleStyle(string: title, color: .red)
            }
            
            return TextStyles.menuTitleStyle(string: title)
        }
        
        titleNode.attributedString = titleStyle
        titleNode.maximumNumberOfLines = 1
        
        if let subtitle = subtitle {
            subtileNode = ASTextNode()
            subtileNode!.attributedString = TextStyles.menuSubtitleStyle(string: subtitle)
            subtileNode!.maximumNumberOfLines = 1
        }
        
        if let icon = icon {
            imageNode = ASImageNode()
            imageNode!.image = icon.imageTintColor(UIColor.baseGray4)
            imageNode!.preferredFrameSize = iconSize
            imageNode!.contentMode = .center
        }
        
        usesImplicitHierarchyManagement = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var textChildren: [ASLayoutable] = [titleNode]
        
        if let subtileNode = subtileNode {
            textChildren.append(subtileNode)
        }
        
        let textSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: textChildren)
        
        var mainChildren: [ASLayoutable] = [textSpec]
        
        if let imageNode = imageNode {
            mainChildren.insert(imageNode, at: 0)
        }
        
        let mainSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: .center,
            children: mainChildren)
        mainSpec.alignSelf = .stretch
        
        let margin: CGFloat = textChildren.count > 1 ? 8.5 : 16
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: margin, left: 15, bottom: margin, right: 15), child: mainSpec)
    }
}
