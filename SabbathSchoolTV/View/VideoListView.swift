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

struct VideoListView: View {
    
    let section: VideoSection
    let didTapLink: ((Clip) -> Void)?
    
    @FocusState private var isFocused
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            HStack {
                Text(section.sectionTitle)
                    .font(.headline)
                    .bold()
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(section.clips) { clip in
                        NavigationLink(destination: PlayerView(clip: clip)) {
                            VideoItemView(clip: clip)
                                .frame(maxWidth: 460)
                                .cornerRadius(10)
                                .padding()
                        }
                        .buttonStyle(PlainNavigationLinkButtonStyle(didTapLink: {
                            didTapLink?(clip)
                        }))
                        
                    }
                }
            }
        }
    }
}
