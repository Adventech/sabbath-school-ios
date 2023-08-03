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

struct DevotionalDocument: View {
    
    @ObservedObject var viewModel: SSPMDocumentViewModel = SSPMDocumentViewModel()
    var didTapLink: (([BibleVerses], String) -> Void)?
    var didClickReference: ((Block.ReferenceScope, String) -> Void)?
    var didScroll: ((CGFloat) -> Void)?
    
    @State private var navBarHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            List {
                if let title = viewModel.document?.title {
                    DocumentHeadNodeV4(title: title, subtitle: viewModel.document?.subtitle)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .transformAnchorPreference(key: SSKey.self, value: .bounds) {
                            $0.append(SSFrame(id: "DocumentHeadNodeV4", frame: geometry[$1]))
                        }
                        .onPreferenceChange(SSKey.self) {
                            didScroll(keyValue: $0)
                        }
                }
                
                ForEach(viewModel.blocks) { blockViewModel in
                    BlockWrapperNodeV4(block: blockViewModel.block, didTapLink: didTapLink, didClickReference: didClickReference)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(.plain)
        }
    }
    
    private func didScroll(keyValue: SSKey.Value) {
        let positionY = keyValue[0].frame.origin.y
        
        if navBarHeight == 0 {
            navBarHeight = positionY
        }
        
        didScroll?(positionY + 150 - abs(navBarHeight))
    }
}

struct DevotionalDocument_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalDocument()
    }
}
