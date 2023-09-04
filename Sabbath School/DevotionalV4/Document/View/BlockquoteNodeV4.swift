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

struct BlockquoteNodeV4: View {
    
    let block: Block.Blockquote
    var didTapLink: (([BibleVerses], String) -> Void)?
    var didClickReference: ((Block.ReferenceScope, String) -> Void)?
    var contextMenuAction: ((ContextMenuAction) -> Void)
    
    var body: some View {
        HStack {
            
            Rectangle()
                .fill(
                    Color(uiColor: .baseGray1)
                )
                .frame(width: 7)
                .cornerRadius(3)
            
            
            if let caption = block.caption, !caption.isEmpty {
                if block.memoryVerse ?? false {
                    Text(AppStyle.Markdown.Text.Blockquote.memoryText(string: caption))
                }
                
                if block.citation ?? false {
                    Text(AppStyle.Markdown.Text.Blockquote.citation(string: caption))
                }
            }
            
            VStack {
                ForEach(block.items, id: \.self) { block in
                    switch block {
                    case .paragraph(let paragraph):
                        ParagraphNodeV4(block: paragraph, didTapLink: didTapLink, contextMenuAction: contextMenuAction)
                    case .heading(let heading):
                        HeadingNodeV4(block: heading)
                    case .list(let list):
                        ListNodeV4(block: list, contextMenuAction: contextMenuAction)
                    case .listItem(let listItem):
                        ListItemNodeV4(block: listItem, index: 0, contextMenuAction: contextMenuAction)
                    case .hr(_):
                        HorizontalLineNodeV4()
                    case .reference(let reference):
                        ReferenceNodeV4(block: reference)
                    case .question(let question):
                        QuestionNodeV4(block: question, didTapLink: didTapLink, contextMenuAction: contextMenuAction)
                    case .blockquote(let blockquote):
                        BlockquoteNodeV4(block: blockquote, contextMenuAction: contextMenuAction)
                    case .collapse(let collapse):
                        CollapseNodeV4(block: collapse, contextMenuAction: contextMenuAction)
                    case .image(let image):
                        ImageNodeV4(block: image)
                    default:
                        DocumentHeadNodeV4(title: "Item errado", subtitle: "Item errado")
                    }
                }
            }
        }
    }
}

struct BlockquoteNodeV4_Previews: PreviewProvider {
    static var previews: some View {

        let block = Block.Blockquote(type: "",
                                     memoryVerse: false,
                                     citation: true,
                                     caption: "¹ And I saw another mighty angel come down from heaven, clothed with a cloud: and a rainbow was upon his head, and his face was as it were the sun, and his feet as pillars of fire:\n² And he had in his hand a little book open: and he set his right foot upon the sea",
                                     items: [])

        BlockquoteNodeV4(block: block, contextMenuAction: { _ in })
    }
}
