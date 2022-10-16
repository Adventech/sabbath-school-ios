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

class ParagraphNode: BlockWrapperNode, TextBlockActionsDelegate {
    private let textNode: ASDisplayNode
    private var block: Block.Paragraph
    private let nested: Bool
    
    override var margins: UIEdgeInsets {
        if nested {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    public init(block: Block.Paragraph, nested: Bool = false) {
        self.nested = nested
        self.block = block
        textNode = TextNode(text: block.markdown, selectable: false)
        super.init()
        (textNode as! TextNode).delegate = self
        self.cornerRadius = 6.0
        addSubnode(textNode)
    }
    
    func didTapLink(value: Any) {
        if let string = value as? String, string.starts(with: "sspmBible://"), let startIndex = string.range(of: "sspmBible://") {
            self.viewController?.didClickBible(bibleVerses: self.block.data?.bible ?? [], verse: String(string[startIndex.upperBound...]))
        }
        
        if let url = value as? String, url.starts(with: "http") {
            self.viewController?.didClickURL(url: URL(string: url)!)
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: paddings, child: textNode)
    }
    
    override func didToggleHighlightBlock(highlight: Bool) {
        if nested { return }
        self.backgroundColor = highlight ? .clear : UIColor(hex: "#B3DFFD")
    }
}
