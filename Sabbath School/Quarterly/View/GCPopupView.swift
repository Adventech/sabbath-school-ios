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

protocol GCPopupViewDelegate: AnyObject {
    func didTapClose()
}

class GCPopupView: ASCellNode {
    weak var delegate: GCPopupViewDelegate?
    
    let closeIcon = ASImageNode()
    let appLogo = ASImageNode()
    let sspmLogo = ASImageNode()
    let descriptionText = ASTextNode()
    let divider = ASDisplayNode()
    var dividerHeight: CGFloat = 1

    override init() {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        
        closeIcon.image = R.image.iconClose()
        appLogo.image = R.image.loginLogo()
        sspmLogo.image = R.image.sspmLogo()
        descriptionText.attributedText = AppStyle.Quarterly.Text.gcPopupText(string: "Welcome to the official app of the General Conference Sabbath School and Personal Ministries Department. Still powered by Adventech, the app will soon receive new improvements in content and features while remaining simple and easy to use. It’s never been easier to study and share God’s Word!".localized())
        
        closeIcon.addTarget(self, action: #selector(tapClose(_:)), forControlEvents: .touchUpInside)
        
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let maxConstrainedSize = constrainedSize.max
        
        closeIcon.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(24), height: ASDimensionMakeWithPoints(24))
        appLogo.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(100), height: ASDimensionMakeWithPoints(100))
        appLogo.style.spacingBefore = 20
        sspmLogo.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(200), height: ASDimensionMakeWithPoints(44))
        sspmLogo.style.spacingBefore = 20
        sspmLogo.style.spacingAfter = 20
        descriptionText.style.spacingBefore = 20
        
        let vSpec1 = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 4,
            justifyContent: .end,
            alignItems: .end,
            children: [closeIcon]
        )
        vSpec1.style.minWidth = ASDimensionMakeWithPoints(maxConstrainedSize.width)
        
        let mainLayout = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [vSpec1, appLogo, descriptionText, sspmLogo]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), child: mainLayout)
    }

    override func layout() {
        super.layout()
    }
    
    @objc func tapClose(_ sender: UIView) {
        delegate?.didTapClose()
    }
}
