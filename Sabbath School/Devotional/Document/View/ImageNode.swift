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

class ImageNode: BlockWrapperNode {
    private let image = ASNetworkImageNode()
    private let caption = ASTextNode()
    private let block: Block.Image
    
    private let internalMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    override var paddings: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private var fullBleed: Bool {
        if let fullBleed = block.style?.fullBleed,
            fullBleed == true {
            return true
        }
        return false
    }
    
    private var rounded: Bool {
        if let rounded = block.style?.rounded,
            rounded == true {
            return true
        }
        return false
    }
    
    override var margins: UIEdgeInsets {
        if self.fullBleed {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return internalMargins
    }
    
    public init(block: Block.Image) {
        self.block = block
        super.init()
        self.caption.maximumNumberOfLines = 2
        self.caption.truncationMode = .byTruncatingTail
        
        self.caption.attributedText = AppStyle.Markdown.Text.Image.caption(string: block.caption ?? "")
        
        self.image.url = block.src
        self.image.cornerRadius = rounded ? 6.0 : 0
        automaticallyManagesSubnodes = true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // TODO: implement image sizes
        self.image.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 200)
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: [image]
        )
        
        if block.caption != nil {
            if self.fullBleed {
                vSpec.children?.append(
                    ASInsetLayoutSpec(insets: internalMargins, child: self.caption)
                )
            } else {
                vSpec.children?.append(self.caption)
            }
        }
        
        return ASInsetLayoutSpec(insets: paddings, child: vSpec)
    }
}
