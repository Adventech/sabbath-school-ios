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

final class AudioPlaylistItemEmptyView: ASCellNode {
    let title = ASDisplayNode()
    let artist = ASDisplayNode()

    override init() {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        title.backgroundColor = AppStyle.Base.Color.shimmering
        artist.backgroundColor = AppStyle.Base.Color.shimmering
        
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        title.style.preferredSize = CGSize(width: constrainedSize.max.width*CGFloat(Float.random(in: 0.5...0.7)), height: 18)
        artist.style.preferredSize = CGSize(width: constrainedSize.max.width*CGFloat(Float.random(in: 0.1...0.37)), height: 10)
        artist.style.spacingBefore = 8

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [title, artist]
        )

        vSpec.style.flexShrink = 1.0

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0), child: vSpec)
    }

    override func layout() {
        super.layout()
        addShimmerToNode(node: title)
        addShimmerToNode(node: artist)
    }
}
