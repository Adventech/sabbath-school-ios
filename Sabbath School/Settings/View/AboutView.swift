/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
        slogan.attributedText = TextStyles.sloganStyle(string: "God's Ministry through Technology".localized())
        instagramLogo.image = R.image.iconInstagram()
        facebookLogo.image = R.image.iconFacebook()
        githubLogo.image = R.image.iconGithub()
        websiteUrl.attributedText = TextStyles.websiteUrlStyle(string: "adventech.io".localized())
        descriptionText.attributedText = TextStyles.descriptionStyle(string: "Mission of Adventech is first and foremost - give glory to our Lᴏʀᴅ, the Ancient of Days. We are dedicated to do our ministry through technology. Our goal is to unite our Seventh-Day Adventist Church. Our goal is to proclaim Good News to this world by means of technology and advancements in communications. Our goal is to witness Jesus’ Second Coming.\n\nWe are inspired by the example and methods of Jesus, when He ministered here on Earth. Therefore, we are committed to deliver high degree of quality of all our projects at absolutely no cost with love and dedication. We are committed to give glory to our Father, because He is worthy of the highest of praise.\n\nWe truly believe that God has increased the knowledge of the modern world and wants us to use it for His glory to proclaim His soon return!".localized())
        signatureText.attributedText = TextStyles.signatureStyle(string: "Your friends at Adventech".localized())

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

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20), child: mainLayout)
    }
    func tapInstagram(_ sender: UIView) {
        delegate?.didTapInstagram()
    }

    func tapFacebook(_ sender: UIView) {
        delegate?.didTapFacebook()
    }

    func tapGitHub(_ sender: UIView) {
        delegate?.didTapGitHub()
    }

    func tapWebsite(_ sender: UIView) {
        delegate?.didTapWebsite()
    }
}
