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

class LessonQuarterlyInfoView: ASCellNode {
    let cover = ASDisplayNode()
    var coverImage: RoundedCornersImage!
    let title = ASTextNode()
    let humanDate = ASTextNode()
    let introduction = ASTextNode()
    let readButton = ASButtonNode()
    let coverCornerRadius = CGFloat(6)

    private let infiniteColor = ASDisplayNode()

    init(quarterly: Quarterly) {
        super.init()

        clipsToBounds = false
        insertSubnode(infiniteColor, at: 0)
        selectionStyle = .none

        if let color = quarterly.colorPrimary {
            backgroundColor = UIColor(hex: color)
        } else {
            backgroundColor = .baseBlue
        }

        // Nodes
        title.attributedText = AppStyle.Quarterly.Text.featuredTitle(string: quarterly.title)
        humanDate.attributedText = AppStyle.Quarterly.Text.humanDate(string: quarterly.humanDate)
        introduction.attributedText = AppStyle.Lesson.Text.introduction(string: quarterly.description, color: .white)
        introduction.maximumNumberOfLines = 8

        readButton.setAttributedTitle(AppStyle.Lesson.Text.readButton(string: "Read".localized().uppercased()), for: .normal)
        readButton.accessibilityIdentifier = "readLesson"
        readButton.titleNode.pointSizeScaleFactors = [0.9, 0.8]
        readButton.backgroundColor = UIColor(hex: (quarterly.colorPrimaryDark)!)
        readButton.contentEdgeInsets = AppStyle.Lesson.Button.readButtonUIEdgeInsets()
        readButton.cornerRadius = 18

        cover.cornerRadius = coverCornerRadius
        cover.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 10
        cover.shadowOpacity = 0.3
        cover.clipsToBounds = false

        coverImage = RoundedCornersImage(imageURL: quarterly.cover, corner: coverCornerRadius, backgroundColor: UIColor(hex: quarterly.colorPrimaryDark!))
        coverImage.style.alignSelf = .stretch

        addSubnode(title)
        addSubnode(humanDate)
        addSubnode(introduction)
        addSubnode(cover)
        addSubnode(coverImage)
        addSubnode(readButton)
    }

    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cover.style.preferredSize = CGSize(width: 130, height: 192)
        title.style.spacingAfter = 28
        readButton.style.spacingBefore = 10

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: [humanDate, title]
        )

        let vSpec2 = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [introduction, readButton]
        )

        vSpec.style.flexShrink = 1.0
        vSpec2.style.flexShrink = 1.0

        let coverSpec = ASBackgroundLayoutSpec(child: coverImage, background: cover)

        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .center,
            alignItems: .center,
            children: [coverSpec, vSpec2]
        )

        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [vSpec, hSpec]
        )

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 35, right: 15), child: mainSpec)
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
