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
    let lineNode1 = ASDisplayNode()
    let lineNode2 = ASDisplayNode()
    let lineNode3 = ASDisplayNode()
    let lineNode4 = ASDisplayNode()
    let lineNode5 = ASDisplayNode()
    let lineNode6 = ASDisplayNode()
    let lineNode7 = ASDisplayNode()
    let lineNode8 = ASDisplayNode()
    let lineNode9 = ASDisplayNode()
    let lineNode10 = ASDisplayNode()
    let lineNode11 = ASDisplayNode()
    let lineNode12 = ASDisplayNode()
    let lineNode13 = ASDisplayNode()
    let lineNode14 = ASDisplayNode()

    override init() {
        super.init()
        coverEmptyNode.backgroundColor = UIColor.baseGray7
        lineNode1.backgroundColor = UIColor.baseGray7
        lineNode2.backgroundColor = UIColor.baseGray7
        lineNode3.backgroundColor = UIColor.baseGray7
        lineNode4.backgroundColor = UIColor.baseGray7
        lineNode5.backgroundColor = UIColor.baseGray7
        lineNode6.backgroundColor = UIColor.baseGray7
        lineNode7.backgroundColor = UIColor.baseGray7
        lineNode8.backgroundColor = UIColor.baseGray7
        lineNode9.backgroundColor = UIColor.baseGray7
        lineNode10.backgroundColor = UIColor.baseGray7
        lineNode11.backgroundColor = UIColor.baseGray7
        lineNode12.backgroundColor = UIColor.baseGray7
        lineNode13.backgroundColor = UIColor.baseGray7
        lineNode14.backgroundColor = UIColor.baseGray7
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height * 0.4)
        
        lineNode1.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode2.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode3.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode4.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode5.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode6.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode7.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode8.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode9.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode10.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode11.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode12.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode13.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        lineNode14.style.preferredSize = CGSize(width: constrainedSize.max.width*(0.5...1).random(), height: 18)
        
        let readSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [
                lineNode1,
                lineNode2,
                lineNode3,
                lineNode4,
                lineNode5,
                lineNode6,
                lineNode7,
                lineNode8,
                lineNode9,
                lineNode10,
                lineNode11,
                lineNode12,
                lineNode13,
                lineNode14
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
        addShimmerToNode(node: lineNode1)
        addShimmerToNode(node: lineNode2)
        addShimmerToNode(node: lineNode3)
        addShimmerToNode(node: lineNode4)
        addShimmerToNode(node: lineNode5)
        addShimmerToNode(node: lineNode6)
        addShimmerToNode(node: lineNode7)
        addShimmerToNode(node: lineNode8)
        addShimmerToNode(node: lineNode9)
        addShimmerToNode(node: lineNode10)
        addShimmerToNode(node: lineNode11)
        addShimmerToNode(node: lineNode12)
        addShimmerToNode(node: lineNode13)
        addShimmerToNode(node: lineNode14)
    }
}
