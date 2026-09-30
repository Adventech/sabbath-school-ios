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

extension DocumentView {
    @ViewBuilder
    func miniHiddenSegment () -> some View {
        if let segment = documentViewOperator.hiddenSegment, !documentViewOperator.shouldShowHiddenSegment {
            Button (action: {
                documentViewOperator.shouldShowHiddenSegment = true
            }) {
                HStack {
                    Button (action: {
                        closeHiddenSegment()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    
                    VStack() {
                        Text(AppStyle.Audio.miniPlayerTitle(segment.title))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if let subtitle = segment.subtitle {
                            Text(AppStyle.Audio.miniPlayerArtist(subtitle))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }.frame(alignment: .leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                }
                .frame(height: AppStyle.Audio.miniPlayerHeight)
                .padding(.horizontal, AppStyle.Audio.miniPlayerContentPadding)
                .frame(width: screenSizeMonitor.screenSize.width - AppStyle.Segment.Spacing.horizontalPaddingHeader(screenSizeMonitor.screenSize.width) * 2)
                .modifier(FloatingControlSurface(cornerRadius: AppStyle.Audio.miniPlayerCornerRadius))
            }
            .buttonStyle(.plain)
        }
    }
    
    func closeHiddenSegment() {
        withAnimation {
            documentViewOperator.shouldShowHiddenSegment = false
            documentViewOperator.hiddenSegment = nil
            documentViewOperator.hiddenSegmentID = nil
        }
    }
}
