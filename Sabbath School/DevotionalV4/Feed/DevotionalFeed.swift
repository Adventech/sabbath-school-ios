//
//  DevotionalFeed.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 24/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

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
