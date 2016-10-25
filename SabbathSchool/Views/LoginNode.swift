//
//  LoginNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 25/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LoginNode: ASDisplayNode {
    let logoNode = ASNetworkImageNode()
    let logoTextNode = ASTextNode()
    let facebookButton = SignInButtonNode(type: .facebook)
    let googleButton = SignInButtonNode(type: .google)
    let anonymousButton = SignInButtonNode(type: .anonymous)
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        logoNode.image = R.image.loginLogo()
        logoTextNode.attributedText = TextStyles.loginLogoTextStyle(string: "Sabbath School")
        
        backgroundColor = UIColor.baseGray1
        usesImplicitHierarchyManagement = true
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let logoSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 8,
            justifyContent: .center,
            alignItems: .center,
            children: [logoNode, logoTextNode])
        
        let buttonsSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 15,
            justifyContent: .center,
            alignItems: .stretch,
            children: [facebookButton, googleButton, anonymousButton])
        
        anonymousButton.spacingBefore = -8
        logoSpec.spacingBefore = 120
        buttonsSpec.spacingAfter = 30
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [logoSpec, buttonsSpec])
        mainSpec.alignSelf = .stretch
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: mainSpec)
    }
}
