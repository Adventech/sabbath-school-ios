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

final class ReadEmptyView: ASCellNode {
    let coverEmptyNode = ASDisplayNode()
    let line1 = ASDisplayNode()
    let line2 = ASDisplayNode()
    let line3 = ASDisplayNode()
    let line4 = ASDisplayNode()
    let line5 = ASDisplayNode()
    let line6 = ASDisplayNode()
    let line7 = ASDisplayNode()
    let line8 = ASDisplayNode()
    let line9 = ASDisplayNode()
    let line10 = ASDisplayNode()
    let line11 = ASDisplayNode()
    let line12 = ASDisplayNode()
    let line13 = ASDisplayNode()
    let line14 = ASDisplayNode()

    override init() {
        super.init()
        coverEmptyNode.backgroundColor = AppStyle.Read.Color.background
        line1.backgroundColor = AppStyle.Read.Color.background
        line2.backgroundColor = AppStyle.Read.Color.background
        line3.backgroundColor = AppStyle.Read.Color.background
        line4.backgroundColor = AppStyle.Read.Color.background
        line5.backgroundColor = AppStyle.Read.Color.background
        line6.backgroundColor = AppStyle.Read.Color.background
        line7.backgroundColor = AppStyle.Read.Color.background
        line8.backgroundColor = AppStyle.Read.Color.background
        line9.backgroundColor = AppStyle.Read.Color.background
        line10.backgroundColor = AppStyle.Read.Color.background
        line11.backgroundColor = AppStyle.Read.Color.background
        line12.backgroundColor = AppStyle.Read.Color.background
        line13.backgroundColor = AppStyle.Read.Color.background
        line14.backgroundColor = AppStyle.Read.Color.background

        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height * 0.4)

        line1.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line2.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line3.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line4.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line5.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line6.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line7.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line8.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line9.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line10.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line11.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line12.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line13.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        line14.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)

        let readSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [
                line1,
                line2,
                line3,
                line4,
                line5,
                line6,
                line7,
                line8,
                line9,
                line10,
                line11,
                line12,
                line13,
                line14
            ]
        )

        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [coverEmptyNode,
                       ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: readSpec)]
        )
    }

    override func layout() {
        super.layout()

        addShimmerToNode(node: coverEmptyNode)
        addShimmerToNode(node: line1)
        addShimmerToNode(node: line2)
        addShimmerToNode(node: line3)
        addShimmerToNode(node: line4)
        addShimmerToNode(node: line5)
        addShimmerToNode(node: line6)
        addShimmerToNode(node: line7)
        addShimmerToNode(node: line8)
        addShimmerToNode(node: line9)
        addShimmerToNode(node: line10)
        addShimmerToNode(node: line11)
        addShimmerToNode(node: line12)
        addShimmerToNode(node: line13)
        addShimmerToNode(node: line14)
    }
}
