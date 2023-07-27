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
    
    var body: some View {
        VStack {
            ForEach(Array((block.items ?? []).enumerated()), id: \.offset) { index, itemBlock in
                switch itemBlock {
                case .listItem(let listItem):
                    if let ordered = block.ordered,
                       let start = block.start,
                       ordered {
                        Text(AppStyle.Markdown.Text.listBullet(string: "\(index + start). " + listItem.markdown, ordered: block.ordered ?? false))
                            .frame(maxWidth: .infinity ,alignment: .leading)
                    } else {
                        switch block.depth {
                        case 1:
                            Text(AppStyle.Markdown.Text.listBullet(string: "● " + listItem.markdown, ordered: block.ordered ?? false))
                                .frame(maxWidth: .infinity ,alignment: .leading)
                        case 2:
                            Text(AppStyle.Markdown.Text.listBullet(string: "○ " + listItem.markdown, ordered: block.ordered ?? false))
                                .frame(maxWidth: .infinity ,alignment: .leading)
                        default:
                            Text(AppStyle.Markdown.Text.listBullet(string: "◆ " + listItem.markdown, ordered: block.ordered ?? false))
                                .frame(maxWidth: .infinity ,alignment: .leading)
                        }
                    }
                default:
                    Text("")
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
                              start: 1,
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

        ListNodeV4(block: list)
    }
}