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

final class LessonEmptyCellNode: ASCellNode {
    let titleEmptyNode = ASDisplayNode()
    let humanDateEmptyNode = ASDisplayNode()

    let divider = ASDisplayNode()
    var dividerHeight: CGFloat = 1

    override init() {
        super.init()

        titleEmptyNode.backgroundColor = UIColor.baseGray1
        humanDateEmptyNode.backgroundColor = UIColor.baseGray1

        // Cell divider
        divider.backgroundColor = UIColor.baseGray1

        addSubnode(divider)
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width*0.56, height: 18)
        humanDateEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width*0.14, height: 10)
        humanDateEmptyNode.style.spacingBefore = 8

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleEmptyNode, humanDateEmptyNode]
        )

        vSpec.style.flexShrink = 1.0

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: vSpec)
    }

    override func layout() {
        super.layout()
        divider.frame = CGRect(x: 0, y: calculatedSize.height-dividerHeight, width: calculatedSize.width, height: dividerHeight)

        addShimmerToNode(node: titleEmptyNode)
        addShimmerToNode(node: humanDateEmptyNode)
    }
}
