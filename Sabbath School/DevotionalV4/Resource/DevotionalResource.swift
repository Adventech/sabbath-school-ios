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
    
    var body: some View {
        
        List {
            DevotionalResourceViewHeaderV4(resource: viewModel.resource, openButtonIndex: "", openButtonTitleText: "Read".localized(), openButtonSubtitleText: "")
                .listRowInsets(EdgeInsets())
            
            ForEach(viewModel.sections) { section in
                DevotionalResourceSectionViewV4(colapsedSection: viewModel.resource.kind == .devotional, section: section, didTapDocument: didTapDocument)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(.plain)
    }
}

struct DevotionalResource_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DevotionalResourceViewModel(id: 0, resource: BlockMockData.generateResource())
        DevotionalResource(viewModel: viewModel)
    }
}
