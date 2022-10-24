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

class CollapseNode: BlockWrapperNode {
    private var nestedBlocks: [ASLayoutElement] = []
    private let header = ASButtonNode()
    private let content = ASDisplayNode()
    private let caption = ASTextNode()
    private let actionIcon = ASImageNode()
    private var collapsed = true
    
    override var paddings: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    public init(block: Block.Collapse) {
        super.init()
        self.nestedBlocks = processBlocks(blocks: block.items, nested: true)
        self.caption.maximumNumberOfLines = 2
        self.caption.truncationMode = .byTruncatingTail
        self.caption.attributedText = AppStyle.Markdown.Text.collapseHeader(string: block.caption)
        self.caption.passthroughNonlinkTouches = true
        
        self.header.backgroundColor = .baseGray1
        self.header.cornerRadius = 4
        self.content.cornerRadius = 4
        self.content.borderWidth = 1
        self.content.borderColor = UIColor.baseGray1.cgColor
        self.content.isUserInteractionEnabled = true
        
        self.header.addTarget(self, action: #selector(didToggleCollapse(_:)), forControlEvents: .touchUpInside)

        automaticallyManagesSubnodes = true
        
        actionIcon.image = R.image.iconMore()?.fillAlpha(fillColor: AppStyle.Markdown.Color.Reference.actionIcon)
        
    }
    
    @objc func didToggleCollapse(_ sender: ASButtonNode) {
        self.collapsed = !self.collapsed
        self.setNeedsLayout()
    }
    
    override func layout() {
        super.layout()
        self.actionIcon.view.transform = CGAffineTransform.identity
        self.actionIcon.view.transform = self.actionIcon.view.transform.rotated(by: self.collapsed ? .pi / 2 : .pi * 1.5)
        self.header.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        if !self.collapsed {
            self.header.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
        self.content.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        caption.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [caption, actionIcon]
        )
        
        hSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        hSpec.style.flexGrow = 1.0
        hSpec.style.alignSelf = .stretch
        
        let vSpecContent = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: nestedBlocks
        )
        
        var vSpecMainChildren: [ASLayoutElement] = [ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: paddings, child: hSpec), background: header)]
        
        if !self.collapsed {
            vSpecMainChildren.append(ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: paddings, child: vSpecContent), background: content))
        }
        
        let vSpecMain = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: vSpecMainChildren
        )
        
        vSpecContent.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
            
        
        return vSpecMain
    }
}
