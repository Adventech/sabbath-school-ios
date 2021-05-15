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
    let sspmLogo = ASImageNode()
    let adventechLogo = ASImageNode()
    let slogan = ASTextNode()
    let instagramLogo = ASImageNode()
    let facebookLogo = ASImageNode()
    let githubLogo = ASImageNode()
    let websiteUrl = ASTextNode()
    let sspmText = ASTextNode()
    let descriptionText = ASTextNode()
    let signatureText = ASTextNode()

    override init() {
        super.init()

        sspmLogo.image = R.image.sspmLogo()
        adventechLogo.image = R.image.logoAdventech()
        slogan.attributedText = TextStyles.sloganStyle(string: "God's Ministry through Technology".localized())
        instagramLogo.image = R.image.iconInstagram()
        facebookLogo.image = R.image.iconFacebook()
        githubLogo.image = R.image.iconGithub()
        websiteUrl.attributedText = TextStyles.websiteUrlStyle(string: "adventech.io".localized())
        
        sspmText.attributedText = TextStyles.descriptionStyle(string: "The mission of the General Conference SSPM Department is to make disciples, who in turn make other disciples. We aim to do this by helping local Seventh-day Adventist churches and their members to discover the purpose and power of Sabbath School and by inspiring and enlisting every member to become actively involved in personal soul-winning service.\n\nThe SSPM Department produces resources to help Seventh-day Adventist church members in their walk with Christ and their witness to the world. The aim of the Sabbath School and Personal Ministries app is to combine many of these resources into one convenient location. As more resources continue to be added, church members and their families will soon be equipped with a wealth of resources to aid them in studying and sharing God’s Word.\n\nTo facilitate the maintenance and development of the app, the SSPM Department is glad to partner with the dedicated and talented team at Adventech.".localized())
        descriptionText.attributedText = TextStyles.descriptionStyle(string: "Adventech is a non-profit organization in Canada that is dedicated to the use of technology for ministry. As dedicated Seventh-day Adventists, the mission of Adventech is first and foremost to give glory to God. We also aim through our ministry to bring unity to the worldwide Seventh-day Adventist Church. Our primary goal is to proclaim the everlasting gospel by means of technology and advancements in communications, and to do our part in preparing the world for the second coming of Jesus.".localized())
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

        adventechLogo.style.spacingBefore = 30
        socialIcons.style.spacingBefore = 31
        websiteUrl.style.spacingBefore = 27
        descriptionText.style.spacingBefore = 20
        signatureText.style.spacingBefore = 20
        signatureText.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
        sspmText.style.spacingBefore = 30
        sspmLogo.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(200), height: ASDimensionMakeWithPoints(44))

        let mainLayout = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [sspmLogo, sspmText, adventechLogo, slogan, socialIcons, websiteUrl, descriptionText, signatureText]
        )

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20), child: mainLayout)
    }
    @objc func tapInstagram(_ sender: UIView) {
        delegate?.didTapInstagram()
    }

    @objc func tapFacebook(_ sender: UIView) {
        delegate?.didTapFacebook()
    }

    @objc func tapGitHub(_ sender: UIView) {
        delegate?.didTapGitHub()
    }

    @objc func tapWebsite(_ sender: UIView) {
        delegate?.didTapWebsite()
    }
}
