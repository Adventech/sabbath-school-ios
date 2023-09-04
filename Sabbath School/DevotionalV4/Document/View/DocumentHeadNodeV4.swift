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

struct DocumentHeadNodeV4: View {
    
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack {
            if let subtitle {
                Text(AppStyle.Markdown.Text.Head.subtitle(string: subtitle))
                    .frame(maxWidth: .infinity ,alignment: .leading)
            }
            Text(AppStyle.Markdown.Text.Head.title(string: title))
                .frame(maxWidth: .infinity ,alignment: .leading)
        }
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 20, trailing: 0))
    }
}

struct DocumentHeadNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        DocumentHeadNodeV4(title: "To Be Like Jesus", subtitle: "Chapter 1")
    }
}
