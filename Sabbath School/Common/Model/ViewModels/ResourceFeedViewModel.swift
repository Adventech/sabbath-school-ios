//
//  ResourceFeedViewModel.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 25/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import Foundation

struct ResourceViewModel: Identifiable {
    let id: Int
    var resourceFeed: ResourceFeed
    
    init(id: Int, resourceFeed: ResourceFeed) {
        self.id = id
        self.resourceFeed = resourceFeed
    }
}

enum ResourceFeedModel {
    case resource
    case resourceGroup
}

class ResourceFeedViewModel: ObservableObject {
    
    @Published var items: [ResourceViewModel]
    
    init(items: [ResourceViewModel]) {
        self.items = items
    }
}

extension ResourceFeedViewModel: Identifiable { }
