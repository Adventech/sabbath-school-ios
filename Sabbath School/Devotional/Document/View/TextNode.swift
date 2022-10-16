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

protocol TextBlockActionsDelegate {
    func didTapLink(value: Any)
}

class TextNode: ASDisplayNode, ASTextNodeDelegate {
    private let text = ASTextNode()
    private var selected: Bool = false
    public var delegate: TextBlockActionsDelegate?
    
    public init(text: String, selectable: Bool = false) {
        super.init()
        let down = Down(markdownString: text)
        
        let downStylerConfiguration = DownStylerConfiguration(
            fonts: SSPMFontCollection(),
            colors: SSPMColorCollection(),
            paragraphStyles: SSPMParagraphStyleCollection()
        )
        
        let styler = SSPMStyler(configuration: downStylerConfiguration)
       
        self.text.delegate = self
        self.text.attributedText = try! down.toAttributedString(styler: styler)
        self.text.isUserInteractionEnabled = true
        self.text.highlightStyle = .dark
        self.text.passthroughNonlinkTouches = true
        
        addSubnode(self.text)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if selected {
            self.backgroundColor = .baseBlue
        }
        
        return ASWrapperLayoutSpec(layoutElement: self.text)
    }
    
    public func textNode(_ textNode: ASTextNode,
                         tappedLinkAttribute attribute: String,
                         value: Any, at point: CGPoint,
                         textRange: NSRange) {
        self.delegate?.didTapLink(value: value)
    }
}
