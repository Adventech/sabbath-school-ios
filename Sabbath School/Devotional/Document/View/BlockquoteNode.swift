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

class BlockquoteNode: BlockWrapperNode {
    private var nestedBlocks: [ASLayoutElement] = []
    private let line = ASDisplayNode()
    private let caption = ASTextNode()
    private let block: Block.Blockquote
    
    public init(block: Block.Blockquote) {
        self.block = block
        super.init()
        
        self.line.backgroundColor = .baseGray1
        self.line.cornerRadius = 3.0
        self.nestedBlocks = processBlocks(blocks: block.items, nested: true)
        
        if let caption = block.caption, !caption.isEmpty {
            if let _ = block.memoryVerse {
                self.caption.attributedText = AppStyle.Markdown.Text.Blockquote.memoryText(string: caption)
            }
            
            if let _ = block.citation {
                self.caption.attributedText = AppStyle.Markdown.Text.Blockquote.citation(string: caption)
            }
        }
        automaticallyManagesSubnodes = true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.line.style.minWidth = ASDimensionMake(7)
        self.line.style.alignSelf = .stretch
        
        
        if let caption = block.caption, !caption.isEmpty {
            let captionBlock = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0), child: self.caption)
            if let _ = block.memoryVerse {
                nestedBlocks.insert(captionBlock, at: 0)
            }
            
            if let _ = block.citation {
                nestedBlocks.append(captionBlock)
            }
        }
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: nestedBlocks
        )
        
        vSpec.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width-15)
        
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 5,
            justifyContent: .start,
            alignItems: .center,
            children: [line, vSpec]
        )
        
        hSpec.style.flexGrow = 1.0
        hSpec.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: hSpec)
    }
}
