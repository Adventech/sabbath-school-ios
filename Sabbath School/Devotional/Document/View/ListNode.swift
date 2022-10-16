/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

class ListItemNode: BlockWrapperNode {
    private let textNode: ASDisplayNode
    public init(text: String) {
        textNode = TextNode(text: text, selectable: false)
        super.init()
        addSubnode(textNode)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: textNode)
    }
}

class ListNode: BlockWrapperNode {
    private let depth: Int
    private var itemNodes: [ASLayoutElement] = []
    
    override var margins: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    override var paddings: UIEdgeInsets {
        let left: CGFloat = (CGFloat(self.depth)-1) * 5.0
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0)
    }
    
    public init(block: Block.List, depth: Int = 1) {
        self.depth = depth
        super.init()
        
        if let items = block.items {
            for (itemIndex, item) in items.enumerated() {
                switch item {
                case .list(let subList):
                    let listItemNode = ListNode(block: subList, depth: depth + 1)
                    addSubnode(listItemNode)
                    itemNodes.append(listItemNode)
                    
                case .listItem(let listItem):
                    let bulletNode = ASTextNode()
                    bulletNode.style.spacingBefore = 5
                    
                    var bullet: String = ""
                    
                    switch self.depth {
                    case 1:
                        bullet = "●"
                    case 2:
                        bullet = "○"
                    default:
                        bullet = "◆"
                    }
                    
                    if let ordered = block.ordered,
                       let start = block.start,
                       ordered {
                       bullet = "\(start + itemIndex)."
                       bulletNode.style.spacingBefore = 0
                    }
                    
                    bulletNode.attributedText = AppStyle.Markdown.Text.listBullet(string: bullet, ordered: block.ordered ?? false)
                    
                    let listItemNode = ListItemNode(text: listItem.markdown)
                    
                    let vSpec = ASStackLayoutSpec(
                        direction: .horizontal,
                        spacing: 10,
                        justifyContent: .start,
                        alignItems: .start,
                        children: [ASStackLayoutSpec(
                            direction: .vertical,
                            spacing: 0,
                            justifyContent: .center,
                            alignItems: .center,
                            children: [bulletNode]
                        ), listItemNode]
                    )
                    
                    addSubnode(bulletNode)
                    addSubnode(listItemNode)
                    
                    listItemNode.style.flexShrink = 1.0
                    
                    itemNodes.append(vSpec)
                default: break
                }
            }
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: itemNodes
        )
        return ASInsetLayoutSpec(insets: paddings, child: vSpec)
    }
}
