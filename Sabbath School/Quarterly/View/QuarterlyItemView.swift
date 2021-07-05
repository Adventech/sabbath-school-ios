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

class QuarterlyItemView: ASCellNode {
    var quarterly: Quarterly
    let cover = ASNetworkImageNode()
    var coverImage: RoundedCornersImage!
    let title = ASTextNode()
    private let coverCornerRadius = CGFloat(6)
    private let coverImageSize = CGSize(width: 150, height: 225)

    init(quarterly: Quarterly) {
        self.quarterly = quarterly
        super.init()
        
        title.attributedText = AppStyle.Quarterly.Text.titleV2(string: quarterly.title)
        title.maximumNumberOfLines = 2
        
        cover.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 5
        cover.shadowOpacity = 0.3
        cover.clipsToBounds = false
        cover.cornerRadius = coverCornerRadius
        
        coverImage = RoundedCornersImage(imageURL: quarterly.cover, corner: coverCornerRadius, size: coverImageSize, backgroundColor: UIColor(hex: quarterly.colorPrimaryDark!))
        coverImage.style.alignSelf = .stretch
        coverImage.imageNode.delegate = self
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cover.style.preferredSize = coverImageSize
        title.style.spacingBefore = 10
        
        let coverSpec = ASBackgroundLayoutSpec(child: coverImage, background: cover)
        
        let mainSpec = ASStackLayoutSpec(
                   direction: .vertical,
                   spacing: 0,
                   justifyContent: .start,
                   alignItems: .start,
                   children: [coverSpec, title])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: mainSpec)
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        cover.layer.shadowPath = UIBezierPath(roundedRect: cover.bounds, cornerRadius: coverCornerRadius).cgPath
    }
}

extension QuarterlyItemView: ASNetworkImageNodeDelegate {
    func imageNodeDidFinishDecoding(_ imageNode: ASNetworkImageNode) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = imageNode.image else { return }
            Spotlight.indexQuarterly(quarterly: self.quarterly, image: image)
        }
    }
}
