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

struct DevotionalResource: View {
    
    @ObservedObject var viewModel: DevotionalResourceViewModel = DevotionalResourceViewModel(id: 0, resource: BlockMockData.generateResource())
    var didTapDocument: ((String) -> Void)?
    var didScroll: ((CGFloat) -> Void)?
    
    @State private var navBarHeight: CGFloat = 0
    
    var body: some View {
        
        let headerData = getHeaderData()
        
        GeometryReader { geometry in
            List {
                DevotionalResourceViewHeaderV4(resource: viewModel.resource,
                                               openButtonIndex: headerData.openButtonIndex,
                                               openButtonTitleText: headerData.openButtonTitleText,
                                               openButtonSubtitleText: headerData.openButtonSubtitleText,
                                               didTapDocument: didTapDocument)
                .listRowInsets(EdgeInsets())
                .transformAnchorPreference(key: SSKey.self, value: .bounds) {
                    $0.append(SSFrame(id: "DevotionalResourceViewHeaderV4", frame: geometry[$1]))
                }
                .onPreferenceChange(SSKey.self) {
                    didScroll(keyValue: $0)
                }
                
                ForEach(viewModel.sections) { section in
                    DevotionalResourceSectionViewV4(colapsedSection: viewModel.resource.kind == .devotional, section: section, didTapDocument: didTapDocument)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
            }
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(.plain)
            .ignoresSafeArea(edges: .top)
        }
    }
    
    private func didScroll(keyValue: SSKey.Value) {
        let positionY = keyValue[0].frame.origin.y
        
        if navBarHeight == 0 {
            navBarHeight = positionY
        }
        
        didScroll?(positionY + (UIScreen.main.bounds.height / 1.7) - abs(navBarHeight))
    }
    
    private func getHeaderData() -> (openButtonIndex: String, openButtonTitleText: String, openButtonSubtitleText: String) {
        
        let today = Date()
        var openButtonIndex = viewModel.sections[safe: 0]?.documents[safe: 0]?.index ?? ""
        var openButtonTitleText = "Read".localized()
        var openButtonSubtitleText = ""
        
        let flatDocuments = viewModel.sections.map({ (document) -> [SSPMDocument] in
            return document.documents
        }).flatMap({ $0 })
        
        if let a = flatDocuments.first(where: {
            $0.date?.day == Calendar.current.component(.day, from: today) &&
            $0.date?.month == Calendar.current.component(.month, from: today) &&
            $0.date?.year == Calendar.current.component(.year, from: today)
        }) {
            
            openButtonIndex = a.index
            openButtonTitleText = a.title
            openButtonSubtitleText = a.subtitle ?? ""        }
        
        return (openButtonIndex, openButtonTitleText, openButtonSubtitleText)
    }
}

struct DevotionalResource_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DevotionalResourceViewModel(id: 0, resource: BlockMockData.generateResource())
        DevotionalResource(viewModel: viewModel)
    }
}
