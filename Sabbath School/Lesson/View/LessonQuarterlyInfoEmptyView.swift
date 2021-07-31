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

final class LessonQuarterlyInfoEmptyView: ASCellNode {
    let cover = ASDisplayNode()
    let title = ASDisplayNode()
    let humanDate = ASDisplayNode()
    let description1 = ASDisplayNode()
    let description2 = ASDisplayNode()
    let description3 = ASDisplayNode()

    let divider = ASDisplayNode()
    var dividerHeight: CGFloat = 1

    override init() {
        super.init()
        
        self.backgroundColor = AppStyle.Base.Color.background
        
        cover.backgroundColor = AppStyle.Base.Color.shimmering
        title.backgroundColor = AppStyle.Base.Color.shimmering
        humanDate.backgroundColor = AppStyle.Base.Color.shimmering
        description1.backgroundColor = AppStyle.Base.Color.shimmering
        description2.backgroundColor = AppStyle.Base.Color.shimmering
        description3.backgroundColor = AppStyle.Base.Color.shimmering
        divider.backgroundColor = AppStyle.Base.Color.shimmering
        
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cover.style.preferredSize = AppStyle.Lesson.Size.coverImage()
        title.style.preferredSize = CGSize(width: constrainedSize.max.width*0.56, height: 18)
        humanDate.style.preferredSize = CGSize(width: constrainedSize.max.width*0.14, height: 10)
        description1.style.preferredSize = CGSize(width: constrainedSize.max.width*0.62, height: 8)
        description2.style.preferredSize = CGSize(width: constrainedSize.max.width*0.62, height: 8)
        description3.style.preferredSize = CGSize(width: constrainedSize.max.width*0.42, height: 8)

        title.style.spacingBefore = 8
        humanDate.style.spacingBefore = 8
        description1.style.spacingBefore = 8
        description2.style.spacingBefore = 4
        description3.style.spacingBefore = 4

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .center,
            alignItems: .center,
            children: [cover, title, humanDate, description1, description2, description3]
        )

        vSpec.style.flexShrink = 1.0

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 95, left: 15, bottom: 15, right: 15), child: vSpec)
    }

    override func layout() {
        super.layout()
        divider.frame = CGRect(x: 0, y: calculatedSize.height-dividerHeight, width: calculatedSize.width, height: dividerHeight)

        addShimmerToNode(node: cover)
        addShimmerToNode(node: title)
        addShimmerToNode(node: humanDate)
        addShimmerToNode(node: description1)
        addShimmerToNode(node: description2)
        addShimmerToNode(node: description3)
    }
}
