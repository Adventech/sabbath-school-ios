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

class LessonQuarterlyInfoSplashView: LessonQuarterlyInfo {
    let coverOverlay = ASDisplayNode()
    var coverImageNode = ASNetworkImageNode()
    var initialCoverHeight: CGFloat = 0

    override init(quarterly: Quarterly) {
        super.init(quarterly: quarterly)
        
        coverImageNode.url = quarterly.splash!
        coverImageNode.contentMode = .scaleAspectFill
        
        coverImageNode.placeholderColor = UIColor(hex: quarterly.colorPrimary!)
        coverImageNode.backgroundColor = UIColor(hex: quarterly.colorPrimary!)
        coverImageNode.placeholderEnabled = true
        coverImageNode.placeholderFadeDuration = 0.6
        coverImage = coverImageNode
        
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverImageNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: AppStyle.Lesson.Size.splashCoverImageHeight())
        title.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
        introduction.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        
        var vSpecChildren: [ASLayoutElement] = [title, humanDate, readView, introduction]
        
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
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 15,
            justifyContent: .center,
            alignItems: .center,
            children: vSpecChildren
        )
        
        let coverOverlaySpec = ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), child: vSpec),
            background: coverOverlay)
        
        let relativeSpec = ASRelativeLayoutSpec(
            horizontalPosition: .center,
            verticalPosition: .end,
            sizingOption: [],
            child: coverOverlaySpec)
        
        let overlaySpec = ASOverlayLayoutSpec(
            child: coverImageNode,
            overlay: relativeSpec)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: overlaySpec)
    }
    
    override func didLoad() {
        super.didLoad()
        initialCoverHeight = coverImage.calculatedSize.height
        if UIAccessibility.isReduceTransparencyEnabled {
            coverOverlay.gradient(from: UIColor.white.withAlphaComponent(0), to: UIColor(hex: quarterly.colorPrimary ?? UIColor.white.hex()))
        } else {
            coverOverlay.gradientBlur(from: UIColor.white.withAlphaComponent(0), to: UIColor.white.withAlphaComponent(1))
        }
    }
}
