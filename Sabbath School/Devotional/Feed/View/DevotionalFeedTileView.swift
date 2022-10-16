/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

class DevotionalFeedTileView: ASCellNode {
    private let resource: Resource
    private let tile: RoundedCornersImage
    private let tileBg = ASDisplayNode()
    private let tileOverlay = ASDisplayNode()
    private let title = ASTextNode()
    private let subtitle = ASTextNode()
    private var inline: Bool
    
    init(resource: Resource, inline: Bool = false) {
        self.resource = resource
        self.inline = inline
        
        self.tile = RoundedCornersImage(
            imageURL: resource.tile ?? resource.cover,
            corner: 4.0,
            size: nil,
            backgroundColor: UIColor(hex: resource.primaryColor)
        )
        
        super.init()
        title.attributedText = AppStyle.Devo.Text.resourceTileTitle(string: resource.title)
        title.maximumNumberOfLines = 2
        title.truncationMode = .byTruncatingTail
        
        subtitle.attributedText = AppStyle.Devo.Text.resourceTileSubtitle(string: resource.subtitle ?? "")
        subtitle.maximumNumberOfLines = 2
        subtitle.truncationMode = .byTruncatingTail
        
        tile.cornerRadius = 4.0
        tile.shadowColor = UIColor.black.cgColor
        tile.shadowOffset = CGSize(width: 0, height: 2)
        tile.shadowRadius = 10
        tile.shadowOpacity = 0.4
        tile.clipsToBounds = false
        tileOverlay.clipsToBounds = true
        tileOverlay.cornerRadius = 4.0
        clipsToBounds = false
        
        selectionStyle = .none
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        tile.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 160)
        subtitle.style.width = ASDimensionMakeWithFraction(0.9)
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .end,
            alignItems: .start,
            children: [title]
        )
        
        if resource.subtitle != nil {
            vSpec.children?.insert(subtitle, at: 0)
        }
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [tile, vSpec]
        )
        
        if inline {
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), child: mainSpec)
        } else {
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0), child: mainSpec)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        if UIAccessibility.isReduceTransparencyEnabled {
            tileOverlay.gradient(
                from: UIColor.white.withAlphaComponent(0),
                to: UIColor(hex: "#012813")
            )
        } else {
            tileOverlay.gradientBlur(
                from: UIColor.white.withAlphaComponent(0),
                to: UIColor(hex: "#012813"),
                locations: [0.0, 0.9, 1]
            )
        }
    }
}
