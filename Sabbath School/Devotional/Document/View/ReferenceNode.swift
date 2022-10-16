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

class ReferenceNode: BlockWrapperNode {
    private let button = ASControlNode()
    private let title = ASTextNode()
    private let subtitle = ASTextNode()
    private let actionIcon = ASImageNode()
    
    private let block: Block.Reference
    
    override var margins: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    override var paddings: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    public init(block: Block.Reference) {
        self.block = block
        super.init()
        self.cornerRadius = 4
        self.backgroundColor = .baseGray1 | .baseGray5
        title.attributedText = AppStyle.Markdown.Text.Reference.title(string: block.title)
        title.maximumNumberOfLines = 1
        title.truncationMode = .byTruncatingTail
        
        if block.subtitle != nil {
            subtitle.attributedText = AppStyle.Markdown.Text.Reference.subtitle(string: block.subtitle!)
            subtitle.maximumNumberOfLines = 1
            subtitle.truncationMode = .byTruncatingTail
        }
        
        actionIcon.image = R.image.iconMore()?.fillAlpha(fillColor: AppStyle.Markdown.Color.Reference.actionIcon)
        
        addSubnode(button)
        addSubnode(title)
        addSubnode(subtitle)
        addSubnode(actionIcon)
        
        button.addTarget(self, action: #selector(didTapReference(_:)), forControlEvents: .touchUpInside)
    }
    
    @objc func didTapReference(_ sender: ASControlNode) {
        self.viewController?.didClickReference(scope: self.block.scope, index: self.block.target)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        title.style.maxWidth = ASDimensionMake(constrainedSize.max.width)
        
        var children: [ASLayoutElement] = [title]
        
        if self.block.subtitle != nil {
            children.insert(self.subtitle, at: 0)
        }
        
        let titles = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: children
        )
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [titles, actionIcon]
        )
        
        titles.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width-40)
        
        return ASInsetLayoutSpec(insets: paddings, child: ASBackgroundLayoutSpec(child: hSpec, background: button))
    }
}
