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
import pop

enum LoginButtonType {
    case facebook
    case google
    case anonymous
}

class LoginButton: ASButtonNode {
    let type: LoginButtonType

    init(type: LoginButtonType) {
        self.type = type
        super.init()

        var attributes: NSAttributedString!
        var icon: UIImage?

        switch type {
        case .facebook:
            attributes = TextStyles.signInButtonTitleStyle(string: "Sign in with Facebook".localized(), color: .white)
            backgroundColor = UIColor.facebook
            icon = R.image.loginIconFacebook()
            accessibilityIdentifier = "signInWithFacebook"
            addShadow()
        case .google:
            attributes = TextStyles.signInButtonTitleStyle(string: "Sign in with Google".localized())
            backgroundColor = UIColor.white
            icon = R.image.loginIconGoogle()
            accessibilityIdentifier = "signInWithGoogle"
            addShadow()
        case .anonymous:
            attributes = TextStyles.signInButtonTitleStyle(string: "Continue without login".localized())
            accessibilityIdentifier = "continueWithoutLogin"
        }

        if let image = icon {
            setImage(image, for: .normal)
        }

        setAttributedTitle(attributes, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 13, left: 30, bottom: 13, right: 30)
        cornerRadius = 4
    }

    func addShadow() {
        shadowColor = UIColor(white: 0, alpha: 0.25).cgColor
        shadowOffset = CGSize(width: 0, height: 1)
        shadowRadius = 0.6
        shadowOpacity = 1
        clipsToBounds = false
    }

    override func sendActions(forControlEvents controlEvents: ASControlNodeEvent, with touchEvent: UIEvent?) {
        if controlEvents == .touchDown {
            let anim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            anim?.duration = 0.2
            anim?.toValue = NSValue(cgSize: CGSize(width: 0.95, height: 0.95))
            self.layer.pop_add(anim, forKey: anim?.property.name)
        }

        if controlEvents == .touchUpInside {
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            anim?.dynamicsTension = 300
            anim?.dynamicsFriction = 16
            anim?.dynamicsMass = 1
            anim?.velocity = NSValue(cgSize: CGSize(width: 2, height: 2))
            anim?.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
            layer.pop_add(anim, forKey: anim?.property.name)
        }

        if controlEvents == .touchDragOutside || controlEvents == .touchCancel {
            let anim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            anim?.duration = 0.2
            anim?.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
            self.layer.pop_add(anim, forKey: anim?.property.name)
        }

        super.sendActions(forControlEvents: controlEvents, with: touchEvent)
    }
}
