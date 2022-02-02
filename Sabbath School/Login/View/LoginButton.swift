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

enum LoginButtonType {
    case google
    case anonymous
}

class LoginButton: ASButtonNode {
    let type: LoginButtonType

    init(type: LoginButtonType) {
        self.type = type
        super.init()
        self.configureStyles(type: type)
    }

    func addShadow() {
        shadowColor = UIColor(white: 0, alpha: 0.25).cgColor
        shadowOffset = CGSize(width: 0, height: 1)
        shadowRadius = 0.6
        shadowOpacity = 1
        clipsToBounds = false
    }
    
    func configureStyles (type: LoginButtonType) {
        var attributes: NSAttributedString!
        var icon: UIImage?
        switch type {
        case .google:
            attributes = AppStyle.Login.Text.signInButton(string: "Sign in with Google".localized())
            backgroundColor = .white
            icon = R.image.loginIconGoogle()
            accessibilityIdentifier = "signInWithGoogle"
            addShadow()
        case .anonymous:
            attributes = AppStyle.Login.Text.signInButtonAnonymous(string: "Continue without login".localized())
            accessibilityIdentifier = "continueWithoutLogin"
        }
        if let image = icon {
            setImage(image, for: .normal)
        }

        setAttributedTitle(attributes, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 13, left: 30, bottom: 13, right: 30)
        cornerRadius = 4
    }
}
