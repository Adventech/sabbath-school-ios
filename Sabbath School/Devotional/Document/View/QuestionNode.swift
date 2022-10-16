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

class QuestionNode: BlockWrapperNode {
    private let question = ASTextNode()
    private let answer = ASEditableTextNode()
    
    public init(block: Block.Question) {
        super.init()
        let down = Down(markdownString: block.markdown)
        
        let downStylerConfiguration = DownStylerConfiguration(
            fonts: SSPMFontCollection(body: R.font.latoBlack(size: 20)!),
            colors: SSPMColorCollection(),
            paragraphStyles: SSPMParagraphStyleCollection()
        )
        
        let styler = SSPMStyler(configuration: downStylerConfiguration)
        self.question.attributedText = try! down.toAttributedString(styler: styler)
        
        self.answer.backgroundColor = .yellow
        self.answer.borderColor = UIColor(hex: "#ECE4C3").cgColor
        self.answer.borderWidth = 1
        self.answer.cornerRadius = 3
        self.answer.backgroundColor = UIColor(hex: "#FFF9DF")
        self.answer.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.answer.typingAttributes = AppStyle.Markdown.Text.answer()
        
        addSubnode(question)
        addSubnode(answer)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        answer.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 200)
        
        let hSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [question, answer]
        )
        
        return ASInsetLayoutSpec(insets: paddings, child: hSpec)
    }
}
