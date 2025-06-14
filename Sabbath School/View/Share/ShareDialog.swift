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

struct ShareDialog: View {
    let shareOptions: ShareOptions
    let featuredTitle: String
    let featuredColor: Color
    @State private var selectedShareGroupIndex = 0
    
    var selectedShareGroup: AnyShareGroup? {
        return shareOptions.shareGroups[safe: selectedShareGroupIndex]
    }
    
    init(shareOptions: ShareOptions, featuredTitle: String, featuredColor: Color = .blue) {
        self.shareOptions = shareOptions
        self.featuredTitle = featuredTitle
        self.featuredColor = featuredColor
        self._selectedShareGroupIndex = State(initialValue: shareOptions.shareGroups.firstIndex(where: { $0.selected == true }) ?? 0)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Picker("", selection: $selectedShareGroupIndex) {
                    ForEach(Array(shareOptions.shareGroups.enumerated()), id:\.offset) { index, shareGroup in
                        Text(shareGroup.title).tag(index)
                    }
                }.pickerStyle(.segmented)
                
                test()
            }
            .padding()
            .background(.white | .black)
            .cornerRadius(10)
            .animation(.easeInOut(duration: 0.3), value: selectedShareGroupIndex)
            
        }
        .background(.clear)
    }
    
    @ViewBuilder
    func test() -> some View {
        VStack {
            if let selectedShareGroup = selectedShareGroup {
                if selectedShareGroup.type == .link, let selectedShareGroupLink = selectedShareGroup.asType(ShareGroupLink.self) {
                    ShareGroupLinkView(
                        shareText: shareOptions.shareText,
                        featuredColor: featuredColor,
                        shareGroup: selectedShareGroupLink
                    )
                }
                
                if selectedShareGroup.type == .file, let selectedShareGroupFile = selectedShareGroup.asType(ShareGroupFile.self) {
                    ShareGroupFileView(
                        fileName: featuredTitle,
                        shareText: shareOptions.shareText,
                        featuredColor: featuredColor,
                        shareGroup: selectedShareGroupFile
                    )
                }
            } else {
                EmptyView()
            }
        }.id(selectedShareGroupIndex)
    }
}
