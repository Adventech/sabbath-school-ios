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

struct ImageNodeV4: View {
    
    let block: Block.Image
    
    var body: some View {
        VStack {
            KFImage(block.src)
                .resizable()
                .scaledToFit()
                .cornerRadius(4)
            Text(AppStyle.Markdown.Text.Image.caption(string: block.caption ?? ""))
                .frame(maxWidth: .infinity ,alignment: .leading)
        }
    }
}

struct ImageNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        let image = Block.Image(type: "image",
                                src: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/assets/img/rr-cover.png")!,
                                caption: "teste",
                                style: nil)
        
        ImageNodeV4(block: image)
    }
}
