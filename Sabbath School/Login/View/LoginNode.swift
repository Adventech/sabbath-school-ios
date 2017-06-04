//
//  LoginNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-25.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LoginNode: ASDisplayNode {
    let logoNode = ASNetworkImageNode()
    let logoTextNode = ASTextNode()
    let facebookButton = LoginButton(type: .facebook)
    let googleButton = LoginButton(type: .google)
    let anonymousButton = LoginButton(type: .anonymous)
    
    override init() {
        super.init()
        
        logoNode.image = R.image.loginLogo()
        
        logoTextNode.attributedText = TextStyles.loginLogoTextStyle(string: "Sabbath School")
        backgroundColor = UIColor.baseGray1
        anonymousButton.style.spacingBefore = -8
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let logoSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 8,
            justifyContent: .center,
            alignItems: .center,
            children: [logoNode, logoTextNode])
        
        logoSpec.style.spacingBefore = 120
        
        let buttonsSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 15,
            justifyContent: .center,
            alignItems: .stretch,
            children: [facebookButton, googleButton, anonymousButton])
        
        buttonsSpec.style.spacingAfter = 30
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [logoSpec, buttonsSpec])
        
        mainSpec.style.alignSelf = .stretch
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: mainSpec)
    }
}
