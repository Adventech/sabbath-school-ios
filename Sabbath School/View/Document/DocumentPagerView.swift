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
    func pagerView(_ resource: Resource, _ document: ResourceDocument, _ segments: [Segment]) -> some View {
        TabView (selection: $documentViewOperator.activeTab) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                segmentPageView(resource: resource, document: document, segment: segment, index: index, maxIndex: segments.count-1)
            }
        }.onAppear {
            documentViewOperator.setShowTabBar(documentViewOperator.shouldShowTabBar(), tab: documentViewOperator.activeTab, force: true)
        }
        .environmentObject(documentViewOperator)
        .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
        .background(themeManager.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .id(document.id)
    }
    
    @ViewBuilder
    func segmentPageView(resource: Resource, document: ResourceDocument, segment: Segment, index: Int, isHiddenSegment: Bool = false, maxIndex: Int) -> some View {
        Group {
            switch segment.type {
            case .story:
                SegmentViewStory(
                    segment: segment,
                    enableTagGesture: !isHiddenSegment
                )
                .tag(index)
                
            case .pdf:
                SegmentViewPDF(
                    segment: segment,
                    allowHorizontalSwipe: isHiddenSegment,
                    showNavigationBarButtons: isHiddenSegment ? .constant(true) : isActiveTabPDF
                )
                .tag(index)
                .environmentObject(viewModel)
                
            case .video:
                SegmentViewBase(
                    resource: resource,
                    segment: segment,
                    index: index,
                    document: document,
                    isHiddenSegment: isHiddenSegment
                ) { cover, blocks, video, title in
                    VStack(spacing: isHiddenSegment ? 40 : 0) {
                        if isHiddenSegment {
                            Rectangle()
                                .fill(Color(uiColor: .baseGray1 | .baseGray2))
                                .cornerRadius(3)
                                .frame(width: 50, height: 5)
                            VStack (spacing: 0) {
                                video
                                title
                                blocks
                            }
                        } else {
                            video.padding(.top, isHiddenSegment ? 0 : 100)
                            title
                            blocks
                        }
                    }.padding(.top, isHiddenSegment ? 10 : 0)
                }
                
            case .block:
                SegmentViewBase(
                    resource: resource,
                    segment: segment,
                    index: index,
                    document: document,
                    isHiddenSegment: isHiddenSegment,
                    progressTrackingTitle:
                        resource.progressTracking == .manual
                            ? (maxIndex == index ? document.title : (document.segments?[safe: index+1]?.title))
                            : nil,
                    progressTrackingSubtitle:
                        resource.progressTracking == .manual
                            ? (maxIndex == index ? document.subtitle : (document.segments?[safe: index+1]?.subtitle))
                            : nil,
                    progressNextSegmentIteratorIndex: resource.progressTracking == .manual ? (maxIndex == index ? nil : index+1) : nil
                ) { cover, blocks, _, header in
                    VStack(spacing: isHiddenSegment ? 40 : 0) {
                        if isHiddenSegment {
                            Rectangle()
                                .fill(Color(uiColor: .baseGray1 | .baseGray2))
                                .cornerRadius(3)
                                .frame(width: 50, height: 5)
                            VStack (spacing: 0) {
                                header
                                blocks
                            }
                        } else {
                            cover
                            blocks
                        }
                    }.padding(.top, isHiddenSegment ? 10 : 0)
                }
                .tag(index)
            }
        }
        .environmentObject(viewModel)
        .environmentObject(viewModel.inlineAudioPlaybackManager)
        .environmentObject(resourceViewModel)
        .environmentObject(documentViewOperator)
        .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
    }
}
