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
                            DevotionalFeedBookViewV4(resource: resource, inline: false)
                        case .resourceGroup(_):
                            DevotionalFeedGroupBookViewNew()
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
