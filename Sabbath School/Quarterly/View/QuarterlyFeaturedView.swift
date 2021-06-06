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

class QuarterlyFeaturedView: ASCellNode {
    let cover = ASNetworkImageNode()
    var coverImage: RoundedCornersImage!
    let title = ASTextNode()
    let humanDate = ASTextNode()
    let openButton = ASButtonNode()
    private let coverCornerRadius = CGFloat(6)
    private let infiniteColor = ASDisplayNode()

    init(quarterly: Quarterly) {
        super.init()

        clipsToBounds = false
        insertSubnode(infiniteColor, at: 0)
        selectionStyle = .none

        if let color = quarterly.colorPrimary {
            backgroundColor = UIColor(hex: color)
        } else {
            backgroundColor = UIColor.baseBlue
        }

        title.attributedText = AppStyle.Quarterly.Text.featuredTitle(string: quarterly.title)
        title.maximumNumberOfLines = 3
        title.pointSizeScaleFactors = [0.9, 0.8]

        humanDate.attributedText = AppStyle.Quarterly.Text.humanDate(string: quarterly.humanDate)
        humanDate.maximumNumberOfLines = 1

        cover.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 10
        cover.shadowOpacity = 0.3
        cover.cornerRadius = coverCornerRadius

        coverImage = RoundedCornersImage(imageURL: quarterly.cover, corner: coverCornerRadius, backgroundColor: UIColor(hex: quarterly.colorPrimaryDark!))
        coverImage.style.alignSelf = .stretch

        openButton.setAttributedTitle(AppStyle.Quarterly.Text.openButton(string: "Open".localized().uppercased()), for: .normal)
        openButton.accessibilityIdentifier = "openLesson"
        openButton.titleNode.pointSizeScaleFactors = [0.9, 0.8]
        openButton.backgroundColor = UIColor(hex: quarterly.colorPrimaryDark!)
        openButton.contentEdgeInsets = AppStyle.Quarterly.Button.openButtonUIEdgeInsets()
        openButton.cornerRadius = 18

        addSubnode(title)
        addSubnode(humanDate)
        addSubnode(cover)
        addSubnode(coverImage)
        addSubnode(openButton)
    }

    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cover.style.preferredSize = CGSize(width: 125, height: 187)
        openButton.style.spacingBefore = 15

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: [humanDate, title, openButton]
        )

        vSpec.style.flexShrink = 1.0

        let coverSpec = ASBackgroundLayoutSpec(child: coverImage, background: cover)

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
        cover.layer.shadowPath = UIBezierPath(roundedRect: cover.bounds, cornerRadius: coverCornerRadius).cgPath
    }
}
