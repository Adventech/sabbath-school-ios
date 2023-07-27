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

struct ReferenceNodeV4: View {
    
    let block: Block.Reference
    var didClickReference: ((Block.ReferenceScope, String) -> Void)?
    
    var body: some View {
        HStack {
            VStack(spacing: 6) {
                if let subtitle = block.subtitle, !subtitle.isEmpty {
                    Text(AppStyle.Markdown.Text.Reference.subtitle(string: subtitle))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity ,alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 18))
                }
                
                Text(AppStyle.Markdown.Text.Reference.title(string: block.title))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity ,alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                
                Spacer(minLength: 9)
            }
            .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
            
            
            Image(uiImage: R.image.iconMore()!.fillAlpha(fillColor: AppStyle.Markdown.Color.Reference.actionIcon))
                .padding(.trailing, 16)
        }
        .background(
            Color(uiColor: .baseGray1 | .baseGray5)
        )
        .cornerRadius(4)
        .onTapGesture {
            didClickReference?(block.scope, block.target)
        }
    }
}

struct ReferenceNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        let block = Block.Reference(type: "type",
                                    target: "target",
                                    scope: Block.ReferenceScope.document,
                                    title: "title",
                                    subtitle: "subtitle")
        
        ReferenceNodeV4(block: block)
    }
}
