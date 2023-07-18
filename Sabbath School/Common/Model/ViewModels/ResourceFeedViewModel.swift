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

struct ResourceModel: Identifiable {
    let id: Int
}


class DevotionalResourceViewModel: Identifiable, ObservableObject {
    let id: Int
    var sections: [SSPMSectionViewModel] = []
    var resource: Resource
    
    init(id: Int, resource: Resource) {
        self.id = id
        self.resource = resource
    }
}

struct SSPMSectionViewModel: Identifiable {
    let id: Int
    let title: String?
    let documents: [SSPMDocument]
}
