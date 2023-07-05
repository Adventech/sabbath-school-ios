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
import Combine

struct DevotionalFeed: View {
    
    @ObservedObject var viewModel = ResourceFeedViewModel(items: [])
    @State private var selectedView: Int?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                    ForEach(viewModel.items) { item in
                        switch item.resourceFeed {
                        case .resource(let resource):
                            if resource.view == .book {
                                DevotionalFeedBookViewV4(resource: resource, inline: false)
                            } else {
                                DevotionalFeedTileViewV4(resource: resource)
                            }
                        case .resourceGroup(let resourceGroup):
                            switch resourceGroup.view {
                            case .list:
                                DevotionalFeedGroupListViewV4(resourceGroup: resourceGroup)
                            case .tileSmall:
                                DevotionalFeedGroupSmallTileViewV4(resourceGroup: resourceGroup)
                            case .tile:
                                DevotionalFeedGroupTileViewV4(resourceGroup: resourceGroup)
                            case .book:
                                DevotionalFeedGroupBookViewV4(resourceGroup: resourceGroup)
                            }
                        }
                    }.listRowSeparator(.hidden)
            }.listStyle(.plain)
        } detail: {
            DevotionalResourceControllerV4()
        }
        
    }
}

struct DevotionalFeed_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BlockMockData.generateResourceFeedViewModel()
        DevotionalFeed(viewModel: viewModel)
    }
}
