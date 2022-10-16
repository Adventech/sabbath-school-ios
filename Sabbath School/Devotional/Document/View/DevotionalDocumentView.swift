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
import Down
import UIKit

func processBlocks(blocks: [Block], nested: Bool = false, viewController: (UIViewController & BlockActionsDelegate)? = nil) -> [ASLayoutElement] {
    var blockNodes: [ASLayoutElement] = []
    for block in blocks {
        
        var blockNode: BlockWrapperNode?
        
        switch block {
        case .heading(let heading):
            blockNode = HeadingNode(block: heading)
        case .paragraph(let paragraph):
            blockNode = ParagraphNode(block: paragraph, nested: nested)
        case .list(let list):
            blockNode = ListNode(block: list)
        case .hr(let hr):
            blockNode = HorizonalLineNode(block: hr)
        case .reference(let reference):
            blockNode = ReferenceNode(block: reference)
        case .question(let question):
            blockNode = QuestionNode(block: question)
        case .blockquote(let blockquote):
            blockNode = BlockquoteNode(block: blockquote)
        case .collapse(let collapse):
            blockNode = CollapseNode(block: collapse)
        case .image(let image):
            blockNode = ImageNode(block: image)
        default: break
        }
        
        if let blockNode = blockNode {
            blockNode.viewController = viewController
            blockNodes.append(BlockNode(block: blockNode))
        }
    }
    return blockNodes
}

class DevotionalDocumentView: ASCellNode {
    private var blockNodes: [ASLayoutElement] = []
    
    init(blocks: [Block], vc: UIViewController & BlockActionsDelegate) {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        self.blockNodes = processBlocks(blocks: blocks, viewController: vc)
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: blockNodes
        )
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0), child: vSpec)
    }
}
