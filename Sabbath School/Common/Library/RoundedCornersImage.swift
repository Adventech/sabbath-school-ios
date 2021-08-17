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

final class RoundedCornersImage: ASDisplayNode {
    var imageNode = ASNetworkImageNode()
    var size: CGSize!

    init(imageURL: URL?, corner: CGFloat, size: CGSize = CGSize(width: 125, height: 187), backgroundColor: UIColor = ASDisplayNodeDefaultPlaceholderColor()) {
        super.init()

        self.size = size
        imageNode.placeholderColor = backgroundColor
        imageNode.backgroundColor = backgroundColor
        imageNode.placeholderEnabled = true
        imageNode.placeholderFadeDuration = 0.6
        imageNode.cornerRadius = corner
        imageNode.clipsToBounds = true

        cornerRadius = corner
        clipsToBounds = true

        if let imageURL = imageURL {
            imageNode.url = imageURL
        }
        

        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.preferredSize = size
        return ASAbsoluteLayoutSpec(children: [imageNode])
    }
}
