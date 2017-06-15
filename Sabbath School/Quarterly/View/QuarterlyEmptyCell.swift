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

final class QuarterlyEmptyCell: ASCellNode {
    let coverEmptyNode = ASDisplayNode()
    let titleEmptyNode = ASDisplayNode()
    let humanDateEmptyNode = ASDisplayNode()
    let descriptionEmptyNode = ASDisplayNode()
    let descriptionEmptyNode2 = ASDisplayNode()
    let descriptionEmptyNode3 = ASDisplayNode()
    
    let divider = ASDisplayNode()
    var dividerHeight: CGFloat = 1
    
    override init() {
        super.init()
        
        coverEmptyNode.style.preferredSize = CGSize(width: 90, height: 135)
        
        coverEmptyNode.backgroundColor = UIColor.baseGray1
        titleEmptyNode.backgroundColor = UIColor.baseGray1
        humanDateEmptyNode.backgroundColor = UIColor.baseGray1
        descriptionEmptyNode.backgroundColor = UIColor.baseGray1
        descriptionEmptyNode2.backgroundColor = UIColor.baseGray1
        descriptionEmptyNode3.backgroundColor = UIColor.baseGray1
        
        // Cell divider
        divider.backgroundColor = UIColor.baseGray1
        
        addSubnode(divider)
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width*0.56, height: 18)
        humanDateEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width*0.14, height: 10)
        descriptionEmptyNode.style.preferredSize = CGSize(width: constrainedSize.max.width*0.62, height: 8)
        descriptionEmptyNode2.style.preferredSize = CGSize(width: constrainedSize.max.width*0.62, height: 8)
        descriptionEmptyNode3.style.preferredSize = CGSize(width: constrainedSize.max.width*0.42, height: 8)
        
        humanDateEmptyNode.style.spacingBefore = 8
        descriptionEmptyNode.style.spacingBefore = 8
        descriptionEmptyNode2.style.spacingBefore = 4
        descriptionEmptyNode3.style.spacingBefore = 4
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleEmptyNode, humanDateEmptyNode, descriptionEmptyNode, descriptionEmptyNode2, descriptionEmptyNode3]
        )
        
        vSpec.style.flexShrink = 1.0
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [coverEmptyNode, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
    
    override func layout() {
        super.layout()
        divider.frame = CGRect(x: 0, y: calculatedSize.height-dividerHeight, width: calculatedSize.width, height: dividerHeight)
        
        addShimmerToNode(node: coverEmptyNode)
        addShimmerToNode(node: titleEmptyNode)
        addShimmerToNode(node: humanDateEmptyNode)
        addShimmerToNode(node: descriptionEmptyNode)
        addShimmerToNode(node: descriptionEmptyNode2)
        addShimmerToNode(node: descriptionEmptyNode3)
    }
}
