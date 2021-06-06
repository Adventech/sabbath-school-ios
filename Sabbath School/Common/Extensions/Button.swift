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
import AuthenticationServices
import UIKit

extension UIButton {
    /**
     Add a space between the text and image
     http://stackoverflow.com/a/25559946/517707
     */
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }

    /**
     Invert image position
     http://stackoverflow.com/a/32174204/517707
     */
    func imageOnRight() {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
}

extension ASButtonNode {
    open override func sendActions(forControlEvents controlEvents: ASControlNodeEvent, with touchEvent: UIEvent?) {
        if controlEvents == .touchDown {
            bounce(true)
        }
        if controlEvents == .touchUpInside || controlEvents == .touchUpOutside || controlEvents == .touchDragOutside {
            bounce(false)
        }
        super.sendActions(forControlEvents: controlEvents, with: touchEvent)
    }
    
    func bounce(_ bounce: Bool) {
        UIView.animate(
            withDuration: bounce ? 0.8 : 0.6,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.8,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { self.transform = bounce ? CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0.95, y: 0.95)) : CATransform3DMakeAffineTransform(CGAffineTransform.identity) },
            completion: nil)
    }
}
