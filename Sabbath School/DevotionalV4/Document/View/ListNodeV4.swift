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

struct ListNodeV4: View {
    
    let block: Block.List
    var didTapLink: (([BibleVerses], String) -> Void)?
    var didClickReference: ((Block.ReferenceScope, String) -> Void)?
    var contextMenuAction: ((ContextMenuAction) -> Void)
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(Array((block.items ?? []).enumerated()), id: \.offset) { index, itemBlock in
                switch itemBlock {
                case .listItem(let listItem):
                    if let ordered = block.ordered,
                       let start = block.start,
                       ordered {
                        ListItemNodeV4(block: listItem, index: index + start, contextMenuAction: contextMenuAction)
                    } else {
                        TextNodeV4(font: R.font.latoMedium(size: 13)!, bibleVerses: [], text: block.bullet + listItem.markdown, contextMenuAction: contextMenuAction)
                    }
                default:
                    BlockWrapperNodeV4(block: itemBlock, didTapLink: didTapLink, didClickReference: didClickReference, contextMenuAction: contextMenuAction)
                }
            }
        }
    }
}

struct ListNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        let list = Block.List(type: "list",
                              depth: 1,
                              ordered: true,
                              start: 10,
                              items: [
                                .listItem(.init(type: "list-item", markdown: "Daily personal prayer")),
                                .listItem(.init(type: "list-item", markdown: "Daily personal study of the Bible")),
                                .listItem(.init(type: "list-item", markdown: "Daily morning and evening family worship")),
                                .listItem(.init(type: "list-item", markdown: "Weekly Sabbath school attendance")),
                                .listItem(.init(type: "list-item", markdown: "Weekly church attendance")),
                                .listItem(.init(type: "list-item", markdown: "Weekly prayer meeting or midweek small-group Bible study attendance")),
                                .listItem(.init(type: "list-item", markdown: "Regular personal witnessing")),
                                .listItem(.init(type: "list-item", markdown: "Regular involvement in local church ministry")),
                              ])

        ListNodeV4(block: list, contextMenuAction: { _ in })
    }
}
