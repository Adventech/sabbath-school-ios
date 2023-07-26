/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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

import SwiftUI

struct DevotionalDocumentViewV4: View {
    
    let block: Block
    var didTapLink: (([BibleVerses], String) -> Void)?
    
    var body: some View {
        switch block {
        case .paragraph(let paragraph):
            ParagraphNodeV4(block: paragraph, didTapLink: didTapLink)
        case .heading(let heading):
            HeadingNodeV4(block: heading)
        case .list(let list):
            ListNodeV4(block: list)
        case .listItem(let listItem):
            DocumentHeadNodeV4(title: "Item errado", subtitle: "Item errado")
        case .hr(let hr):
            HorizontalLineNodeV4()
        case .reference(let reference):
            ReferenceNodeV4()
        case .question(let question):
            QuestionNodeV4()
        case .blockquote(let blockquote):
            BlockquoteNodeV4()
        case .collapse(let collapse):
            CollapseNodeV4()
        case .image(let image):
            ImageNodeV4()
        default:
            DocumentHeadNodeV4(title: "Item errado", subtitle: "Item errado")
        }
    }
}

struct DevotionalDocumentViewV4_Previews: PreviewProvider {
    static var previews: some View {
        let paragraph = Block.Paragraph(type: "paragraph",
                                        markdown: "A disciple is not above his teacher, but everyone who is perfectly trained will be like his teacher” ([Luke 6:40](sspmBible://Luke640)). This one short statement outlines the object of the Christian life. The goal of every true disciple is to be like Jesus.",
                                        data: nil)
        let block = Block.paragraph(paragraph)
        
        DevotionalDocumentViewV4(block: block)
    }
}
