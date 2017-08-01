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

        logoTextNode.attributedText = TextStyles.loginLogoTextStyle(string: "Sabbath School".localized())
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
