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

class QuarterlyCellNode: ASCellNode {
    let coverNode = ASDisplayNode()
    var coverImageNode: RoundedCornersImage!
    let titleNode = ASTextNode()
    let humanDateNode = ASTextNode()

    init(quarterly: Quarterly) {
        super.init()
        backgroundColor = UIColor.white
        
        titleNode.attributedText = TextStyles.h3(string: quarterly.title)
        humanDateNode.attributedText = TextStyles.uppercaseHeader(string: quarterly.humanDate, color: .baseGray2)

        coverNode.cornerRadius = 6
        coverNode.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        coverNode.shadowOffset = CGSize(width: 0, height: 2)
        coverNode.shadowRadius = 10
        coverNode.shadowOpacity = 0.3
        coverNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
        coverNode.clipsToBounds = false

        coverImageNode = RoundedCornersImage(
            imageURL: quarterly.cover,
            corner: coverNode.cornerRadius,
            size: CGSize(width: 90, height: 135)
        )
        coverImageNode.style.alignSelf = .stretch
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: 90, height: 135)

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: [humanDateNode, titleNode]
        )
        
        vSpec.style.flexShrink = 1.0

        let coverSpec = ASBackgroundLayoutSpec(child: coverImageNode, background: coverNode)
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .center,
            children: [coverSpec, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15), child: hSpec)
    }

    override func layoutDidFinish() {
        super.layoutDidFinish()
        coverNode.layer.shadowPath = UIBezierPath(roundedRect: coverNode.bounds, cornerRadius: 6).cgPath
    }
}

