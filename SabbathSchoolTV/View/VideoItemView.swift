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
import Combine
import Foundation

struct VideoItemView: View {
    
    let clip: Clip
    
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @State var image: UIImage = UIImage()
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: 384, height: 215)
                .clipped()
                .cornerRadius(10)
                .shadow(radius: 5)
                .onAppear(perform: {
                    if image.size == .zero {
                        imageLoader.loadImage(urlString: clip.thumbnail)
                    } else {
                        let imageUpdated = self.image
                        self.image = imageUpdated
                    }
                    
                })
                .onReceive(imageLoader.didChange) { image in
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
                .background(content: {
                    ShimmerEffectBox()
                })
            
            Text(clip.title)
                .fontWeight(.medium)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity ,alignment: .leading)
                .frame(width: 384)
        }
    }
}
