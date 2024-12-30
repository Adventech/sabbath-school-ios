/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
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

struct FeedResourceViewBanner: View {
    var title: String
    var subtitle: String?
    var cover: URL
    var externalURL: URL?
    var primaryColor: String?
    var direction: FeedGroupDirection
    var scaleFactor: CGFloat = 1
    var backgroundColorEnabled: Bool = true
    var showTitle: Bool = true
    
    var body: some View {
        FeedResourceViewBase(direction: direction,
                             viewType: .banner,
                             coverType: .landscape,
                             content: { dimensions in
            ZStack (alignment: .bottomLeading) {
                FeedGroupItemCoverView(cover, dimensions, primaryColor, scaleFactor)
                
                if showTitle {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(width: dimensions.width * scaleFactor, height: dimensions.height*scaleFactor*0.4)
                        .mask {
                            VStack(spacing: 0){
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0),
                                        Color.white.opacity(0.303),
                                        Color.white.opacity(0.707),
                                        Color.white.opacity(0.924),
                                        Color.white
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                Rectangle()
                                    .frame(height: dimensions.height*scaleFactor*0.1)
                            }.cornerRadius(6)
                            
                        }
                    FeedGroupItemTitleView(title, subtitle, dimensions, direction, false, externalURL: externalURL, scaleFactor, true)
                        .frame(width: dimensions.width * scaleFactor - AppStyle.Feed.Spacing.horizontalPadding * 2, alignment: .leading)
                        .padding(AppStyle.Feed.Spacing.insideBanner)
                }
            }.frame(width: dimensions.width * scaleFactor)
        })
    }
}
