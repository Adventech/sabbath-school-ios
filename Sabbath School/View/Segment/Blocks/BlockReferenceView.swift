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
import NukeUI

struct BlockReferenceView: StyledBlock, View {
    var block: Reference
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    
    var body: some View {
        if let segment = block.segment, block.scope == .segment {
            Button(action: {
                if documentViewOperator.hiddenSegmentID == segment.index {
                    documentViewOperator.shouldShowHiddenSegment.toggle()
                } else {
                    documentViewOperator.hiddenSegmentIterator += 1
                    documentViewOperator.hiddenSegmentID = segment.index
                }
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                label
            }.frame(maxWidth: .infinity)
            .padding(10)
            .background(AppStyle.Block.Reference.backgroundColor(theme: themeManager.currentTheme))
            .buttonStyle(.plain)
            .cornerRadius(6)
        } else {
            NavigationLink {
                if let resource = block.resource,
                   block.scope == .resource {
                    ResourceView(resourceIndex: resource.index)
                } else if let document = block.document,
                          block.scope == .document {
                    DocumentView(documentIndex: document.index)
                } else {
                    EmptyView()
                }
            } label: {
                label
            }
            .frame(maxWidth: .infinity)
            .background(AppStyle.Block.Reference.backgroundColor(theme: themeManager.currentTheme))
            .buttonStyle(.plain)
            .cornerRadius(6)
        }
    }
    
    var isHiddenSegment: Bool {
        return block.scope == .segment && block.segment != nil
    }
    
    var label: some View {
        HStack {
            if let resource = block.resource, !isHiddenSegment {
                LazyImage(url: resource.covers.portrait) { state in
                    if let image = state.image {
                        image.resizable()
                    } else {
                        Color(hex: resource.primaryColor)
                    }
                    
                }
                .frame(width: AppStyle.Block.Reference.thumbnailSize.width, height: AppStyle.Block.Reference.thumbnailSize.height)
                .cornerRadius(6)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
            }
            
            VStack (alignment: .leading, spacing: 5) {
                Text(block.title)
                    .lineLimit(2)
                    .font(.custom("Lato-Bold", size: 16))
                    .foregroundColor(themeManager.getTextColor())

                if let subtitle = block.subtitle {
                    Text(subtitle)
                        .lineLimit(1)
                        .font(.custom("Lato-Medium", size: 14))
                        .foregroundColor(themeManager.getTextColor().opacity(0.7))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(themeManager.getTextColor())
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}
