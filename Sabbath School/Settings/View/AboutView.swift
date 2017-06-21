//
//  AboutView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-20.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol AboutViewDelegate: class {
    func didTapInstagram()
    func didTapFacebook()
    func didTapGitHub()
    func didTapWebsite()
}

class AboutView: ASCellNode {
    weak var delegate: AboutViewDelegate?
    let adventechLogo = ASImageNode()
    let slogan = ASTextNode()
    let instagramLogo = ASImageNode()
    let facebookLogo = ASImageNode()
    let githubLogo = ASImageNode()
    let websiteUrl = ASTextNode()
    let descriptionText = ASTextNode()
    let signatureText = ASTextNode()
    
    override init() {
        super.init()
        
        adventechLogo.image = R.image.logoAdventech()
        slogan.attributedText = TextStyles.sloganStyle(string: "God’s Ministry through technology".localized())
        instagramLogo.image = R.image.iconInstagram()
        facebookLogo.image = R.image.iconFacebook()
        githubLogo.image = R.image.iconGithub()
        websiteUrl.attributedText = TextStyles.websiteUrlStyle(string: "adventech.io".localized())
        descriptionText.attributedText = TextStyles.descriptionStyle(string: "Our mission is to glorify the Ancient of Days by helping official Adventist ministries and churches in technology. By empowering passionate and technologically advanced believers we want to up the bar of existing resources that support Adventist initiatives in this digitally connected world.\n\nOur mission is to glorify the Ancient of Days by helping official Adventist ministries and churches in technology. By empowering passionate and technologically advanced believers we want to up the bar of existing resources that support Adventist initiatives in this digitally connected world.".localized())
        signatureText.attributedText = TextStyles.signatureStyle(string: "Your friends at Adventech")
        
        instagramLogo.addTarget(self, action: #selector(tapInstagram(_:)), forControlEvents: .touchUpInside)
        facebookLogo.addTarget(self, action: #selector(tapFacebook(_:)), forControlEvents: .touchUpInside)
        githubLogo.addTarget(self, action: #selector(tapGitHub(_:)), forControlEvents: .touchUpInside)
        websiteUrl.addTarget(self, action: #selector(tapWebsite(_:)), forControlEvents: .touchUpInside)
        
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        adventechLogo.style.preferredSize = CGSize(width: 213, height: 108)
        slogan.style.spacingBefore = 9
        
        let socialIcons = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 30,
            justifyContent: .center,
            alignItems: .center,
            children: [instagramLogo, facebookLogo, githubLogo])
        
        socialIcons.style.spacingBefore = 31
        websiteUrl.style.spacingBefore = 27
        descriptionText.style.spacingBefore = 20
        signatureText.style.spacingBefore = 20
        signatureText.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
        
        let mainLayout = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [adventechLogo, slogan, socialIcons, websiteUrl, descriptionText, signatureText]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 37, left: 20, bottom: 20, right: 20), child: mainLayout)
    }
    
    func tapInstagram(_ sender: UIView){
        delegate?.didTapInstagram()
    }
    
    func tapFacebook(_ sender: UIView){
        delegate?.didTapFacebook()
    }
    
    func tapGitHub(_ sender: UIView){
        delegate?.didTapGitHub()
    }
    
    func tapWebsite(_ sender: UIView){
        delegate?.didTapWebsite()
    }
}
