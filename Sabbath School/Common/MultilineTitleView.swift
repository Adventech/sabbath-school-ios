/*
 * Copyright (c) 2025 Adventech <info@adventech.io>
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

struct MultilineTitleView<Content: View, LargeLabel: View, SmallLabel: View>: View {
    var trailingOffset: CGFloat = 0.0
    @ViewBuilder var content: Content
    @ViewBuilder var largeLabel: () -> LargeLabel
    @ViewBuilder var smallLabel: () -> SmallLabel
    @State var showToolbarTitle: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                largeLabel()
                    .padding(.trailing, trailingOffset)
                    .overlay {
                        GeometryReader { geo in
                            EmptyView()
                                .onChange(of: geo.frame(in: .named("container"))) { newValue in
                                    let heightOfViewShowing = newValue.maxY - 5.0
                                    withAnimation {
                                        showToolbarTitle = (heightOfViewShowing <= 0.0)
                                    }
                                }
                        }
                    }
                    .padding(.bottom)
                content
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                smallLabel()
                    .padding(.trailing, trailingOffset)
                    .opacity(showToolbarTitle ? 1.0 : 0.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .coordinateSpace(name: "container")
    }
}
