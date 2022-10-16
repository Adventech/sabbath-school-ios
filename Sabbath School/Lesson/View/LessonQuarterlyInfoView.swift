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

class LessonQuarterlyInfo: ASCellNode {
    var quarterly: Quarterly?
    let title = ASTextNode()
    let humanDate = ASTextNode()
    let introduction = ASTextNode()
    let readButton = ReadButtonNode()
    var coverImage = ASImageNode()
    var features: [ASNetworkImageNode] = []
    
    init(quarterly: Quarterly) {
        super.init()
        self.quarterly = quarterly
        selectionStyle = .none

        title.attributedText = AppStyle.Quarterly.Text.featuredTitle(string: quarterly.title)
        humanDate.attributedText = AppStyle.Quarterly.Text.humanDate(string: quarterly.humanDate)
        introduction.attributedText = AppStyle.Lesson.Text.introduction(string: quarterly.description)
        introduction.maximumNumberOfLines = 3
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.baseBlue.lighter(componentDelta: 0.4),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: R.font.latoMediumItalic(size: 15)!
        ]
        
        let blurb: NSString = NSString(format: "%@%@", "… ", "More".localized().lowercased() as NSString)
        let string = NSMutableAttributedString(string: blurb as String)
        string.addAttribute(.foregroundColor, value: UIColor.white, range: NSMakeRange(0, 2))
        string.addAttributes(attributes, range: blurb.range(of: "More".localized().lowercased()))
        introduction.truncationAttributedText = string

        readButton.setAttributedTitle(AppStyle.Lesson.Text.readButton(string: "Read".localized().uppercased()), for: .normal)
        readButton.accessibilityIdentifier = "readLesson"
        readButton.titleNode.pointSizeScaleFactors = [0.9, 0.8]
        readButton.backgroundColor = UIColor(hex: (quarterly.colorPrimaryDark)!)
        readButton.contentEdgeInsets = AppStyle.Lesson.Button.readButtonUIEdgeInsets()
        readButton.cornerRadius = 18

        for feature in quarterly.features {
            let image = ASNetworkImageNode()
            image.url = feature.image
            image.imageModificationBlock = ASImageNodeTintColorModificationBlock(.white)
            image.alpha = 0.5
            self.features.append(image)
            addSubnode(image)
        }

        addSubnode(title)
        addSubnode(humanDate)
        addSubnode(introduction)
        addSubnode(readButton)
    }
}

class LessonQuarterlyInfoView: LessonQuarterlyInfo {
    let cover = ASDisplayNode()
    var coverImageNode: RoundedCornersImage!
    let coverCornerRadius = CGFloat(6)
    
    private let infiniteColor = ASDisplayNode()

    override init(quarterly: Quarterly) {
        super.init(quarterly: quarterly)
        
        clipsToBounds = false
        insertSubnode(infiniteColor, at: 0)
        selectionStyle = .none

        if let color = quarterly.colorPrimary {
            backgroundColor = UIColor(hex: color)
        } else {
            backgroundColor = .baseBlue
        }
        
        cover.cornerRadius = coverCornerRadius
        cover.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 10
        cover.shadowOpacity = 0.3
        cover.clipsToBounds = false

        coverImageNode = RoundedCornersImage(imageURL: quarterly.cover, corner: coverCornerRadius, size: AppStyle.Lesson.Size.coverImage(), backgroundColor: UIColor(hex: quarterly.colorPrimaryDark!))
        coverImageNode.style.alignSelf = .stretch
        coverImage = coverImageNode.imageNode

        addSubnode(title)
        addSubnode(humanDate)
        addSubnode(introduction)
        addSubnode(cover)
        addSubnode(coverImageNode)
        addSubnode(readButton)
    }
    
    override func didLoad() {
        infiniteColor.backgroundColor = backgroundColor
        super.didLoad()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cover.style.preferredSize = AppStyle.Lesson.Size.coverImage()
        coverImageNode.style.preferredSize = AppStyle.Lesson.Size.coverImage()
        introduction.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)

        let coverSpec = ASBackgroundLayoutSpec(child: coverImageNode, background: cover)
        let coverHSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [coverSpec])
        
        let isHorizontal = Helper.isPad && constrainedSize.max.width > 600
        
        var vSpecChildren: [ASLayoutElement] = [title, humanDate, introduction]
        
        if (features.count > 0) {
            var featuresSpecChildren: [ASLayoutElement] = []
            
            for feature in features {
                feature.style.preferredSize = AppStyle.Lesson.Size.featureImage()
                featuresSpecChildren.append(feature)
            }
            let featureHStack = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 15,
                justifyContent: .start,
                alignItems: .start,
                children: featuresSpecChildren)
            
            
            featureHStack.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
            vSpecChildren.append(featureHStack)
        }
        
        if !isHorizontal {
            vSpecChildren.insert(readButton, at: 2)
        } else {
            vSpecChildren.append(readButton)
        }
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 15,
            justifyContent: isHorizontal ? .start : .center,
            alignItems: isHorizontal ? .start : .center,
            children: vSpecChildren
        )
        
        vSpec.style.flexShrink = 1.0
        
        let mainSpec = ASStackLayoutSpec(
            direction: isHorizontal ? .horizontal : .vertical,
            spacing: 20,
            justifyContent: isHorizontal ? .start : .center,
            alignItems: isHorizontal ? .center : .center,
            children: [coverHSpec, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 95, left: 20, bottom: 25, right: 20), child: mainSpec)
    }

    override func layout() {
        super.layout()
        infiniteColor.frame = CGRect(x: 0, y: calculatedSize.height-2000, width: calculatedSize.width, height: 2000)
    }

    override func layoutDidFinish() {
        super.layoutDidFinish()
        cover.layer.shadowPath = UIBezierPath(roundedRect: cover.bounds, cornerRadius: coverCornerRadius).cgPath
    }
}
