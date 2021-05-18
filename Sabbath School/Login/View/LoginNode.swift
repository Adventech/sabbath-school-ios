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
import AuthenticationServices

class LoginNode: ASDisplayNode {
    let logoNode = ASNetworkImageNode()
    let logoTextNode = ASTextNode()
    let facebookButton = LoginButton(type: .facebook)
    let googleButton = LoginButton(type: .google)
    let anonymousButton = LoginButton(type: .anonymous)
    var signInWithAppleButtonNode: ASDisplayNode?
    
    override init() {
        super.init()
        logoNode.image = R.image.loginLogo()
        logoNode.contentMode = .scaleAspectFit
        self.configureStyles()
        backgroundColor = .baseBackgroundLogin
        anonymousButton.style.spacingBefore = -8
        automaticallyManagesSubnodes = true
    }
    
    func configureStyles () {
        logoTextNode.attributedText = TextStyles.loginLogoTextStyle(string: "Sabbath School".localized())
        if #available(iOS 13.0, *) {
            self.signInWithAppleButtonNode = ASDisplayNode { () -> UIView in
                let signInWithAppleButton = ASAuthorizationAppleIDButton(
                    authorizationButtonType: .signIn,
                    authorizationButtonStyle: getSettingsTheme() == Theme.Dark.rawValue ? .white : .black
                )
                signInWithAppleButton.cornerRadius = 5
                signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
                
                print("SSDEBUG", "fdsfdsds")

                return signInWithAppleButton
            }
        }
        anonymousButton.configureStyles(type: .anonymous)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        logoNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(.auto, 0), height: ASDimensionMakeWithPoints(120))
        
        let logoSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 8,
            justifyContent: .center,
            alignItems: .center,
            children: [logoNode, logoTextNode])

        logoSpec.style.spacingBefore = 80
        
        let buttonsSpec = ASStackLayoutSpec()
        buttonsSpec.direction = .vertical
        buttonsSpec.spacing = 15
        buttonsSpec.justifyContent = .center
        buttonsSpec.alignItems = .stretch
        
        if #available(iOS 13.0, *) {
            signInWithAppleButtonNode?.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(240), height: ASDimensionMakeWithPoints(45))
            buttonsSpec.children = [signInWithAppleButtonNode!, facebookButton, googleButton, anonymousButton]
        } else {
            buttonsSpec.children = [facebookButton, googleButton, anonymousButton]
        }

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
