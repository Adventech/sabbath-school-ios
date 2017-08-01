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

class QuarterlyFeaturedCellNode: ASCellNode {
    let coverNode = ASNetworkImageNode()
    var coverImageNode: RoundedCornersImage!
    let titleNode = ASTextNode()
    let humanDateNode = ASTextNode()
    let openButton = OpenButton()

    private let infiniteColor = ASDisplayNode()

    init(quarterly: Quarterly) {
        super.init()

        if let color = quarterly.colorPrimary {
            backgroundColor = UIColor(hex: color)
        } else {
            backgroundColor = UIColor.baseGreen
        }

        clipsToBounds = false
        insertSubnode(infiniteColor, at: 0)
        selectionStyle = .none

        titleNode.attributedText = TextStyles.h2(string: quarterly.title)
        titleNode.maximumNumberOfLines = 3
        titleNode.pointSizeScaleFactors = [0.9, 0.8]

        humanDateNode.attributedText = TextStyles.uppercaseHeader(string: quarterly.humanDate)
        humanDateNode.maximumNumberOfLines = 1

        coverNode.cornerRadius = 6
        coverNode.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        coverNode.shadowOffset = CGSize(width: 0, height: 2)
        coverNode.shadowRadius = 10
        coverNode.shadowOpacity = 0.3
        coverNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
        coverNode.clipsToBounds = false

        coverImageNode = RoundedCornersImage(imageURL: quarterly.cover, corner: coverNode.cornerRadius)
        coverImageNode.style.alignSelf = .stretch

        openButton.setAttributedTitle(TextStyles.readButtonStyle(string: "Open".localized().uppercased()), for: .normal)
        openButton.accessibilityIdentifier = "openLesson"
        openButton.titleNode.pointSizeScaleFactors = [0.9, 0.8]
        openButton.backgroundColor = UIColor(hex: (quarterly.colorPrimaryDark)!)
        openButton.contentEdgeInsets = ButtonStyle.openButtonUIEdgeInsets()
        openButton.cornerRadius = 18

        addSubnode(titleNode)
        addSubnode(humanDateNode)
        addSubnode(coverNode)
        addSubnode(coverImageNode)
        addSubnode(openButton)
    }

    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: 125, height: 187)
        openButton.style.spacingBefore = 15

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: [humanDateNode, titleNode, openButton]
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

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15), child: hSpec)
    }

    override func layout() {
        super.layout()
        infiniteColor.frame = CGRect(x: 0, y: calculatedSize.height-1000, width: calculatedSize.width, height: 1000)
    }

    override func layoutDidFinish() {
        super.layoutDidFinish()
        coverNode.layer.shadowPath = UIBezierPath(roundedRect: coverNode.bounds, cornerRadius: 6).cgPath
    }
}
