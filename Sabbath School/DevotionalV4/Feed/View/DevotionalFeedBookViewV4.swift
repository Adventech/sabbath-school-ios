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
import Kingfisher

struct DevotionalFeedBookViewV4: View {
    
    let resource: Resource
    let inline: Bool
    var didTapResource: ((String) -> Void)?
    
    var body: some View {
        HStack(spacing: 20) {
            KFImage(resource.cover)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 140)
                .cornerRadius(4)
                .shadow(color: Color(UIColor(white: 0, alpha: 0.6)), radius: 4, x: 0, y: 0)
            VStack(spacing: 8) {
                Text(AppStyle.Devo.Text.resourceListSubtitle(string: resource.subtitle ?? ""))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity ,alignment: .leading)
                
                Text(AppStyle.Devo.Text.resourceListTitle(string: resource.title))
                    .frame(maxWidth: .infinity ,alignment: .leading)
                
            }
        }
        .padding(EdgeInsets(top: 1, leading: inline ? 20 : 0, bottom: 1, trailing: inline ? 20 : 0))
        .onTapGesture {
            didTapResource?(resource.index)
        }
    }
}

struct DevotionalFeedBookViewNew_Previews: PreviewProvider {
    static var previews: some View {
        let resource = BlockMockData.generateResource()
        DevotionalFeedBookViewV4(resource: resource, inline: true)
    }
}
