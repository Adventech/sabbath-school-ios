//
//  BlockData.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 25/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import Foundation

class BlockMockData: ObservableObject {
    static func generateResource() -> Resource {
        return Resource(id: "discipleship-handbook",
                        index: "en/pm/discipleship-handbook",
                        title: "Discipleship Handbook",
                        subtitle: "A Resource for Seventh-day Adventist Church Members. The Discipleship Handbook is part of the GROW Your Church series of Personal Ministries resources.",
                        description: nil,
                        cover: URL(string: "https://sabbath-school.adventech.io/api/v2/en/pm/discipleship-handbook/assets/img/cover.png"),
                        tile: nil,
                        splash: nil,
                        primaryColor: "#BD1F3E",
                        primaryColorDark: "#000000",
                        textColor: "#ffffff",
                        credits: nil,
                        view: .book,
                        sections: nil,
                        kind: .book)
    }
    
    static func generateTileResource() -> Resource {
        return Resource(id: "bhp-bible-2022", index: "en/study/bhp-bible-2022", title: "Believe His Prophets Bible Reading", subtitle: "A five-year program reading through the Bible", description: nil, cover: nil, tile: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/bhp-bible-2022/assets/img/tile.png"), splash: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/bhp-bible-2022/assets/img/splash.png"), primaryColor: "#333333", primaryColorDark: "#000000", textColor: "#ffffff", credits: [], view: .tile, sections: nil, kind: .devotional)
    }
    
    static func generateBookTileResource() -> Resource {
        return Resource(id: "youth-devotional-2022",
                        index: "en/study/youth-devotional-2022",
                        title: "Youth Devotional",
                        subtitle: "I will Go Youth Devotional for 2022",
                        description: nil,
                        cover: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/youth-devotional-2022/assets/img/cover.png"),
                        tile: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/youth-devotional-2022/assets/img/tile.png"),
                        splash: nil,
                        primaryColor: "#1A2B32",
                        primaryColorDark: "#061A22",
                        textColor: "#ffffff",
                        credits: [],
                        view: .tile,
                        sections: nil,
                        kind: .book)
    }
    
    static func generateTileResourceGroup() -> ResourceGroup {
        
        let resource = Resource(id: "youth-devotional-2022",
                                index: "en/study/youth-devotional-2022",
                                title: "Youth Devotional",
                                subtitle: "I will Go Youth Devotional for 2022",
                                description: nil,
                                cover: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/youth-devotional-2022/assets/img/cover.png"),
                                tile: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/youth-devotional-2022/assets/img/tile.png"),
                                splash: nil,
                                primaryColor: "#1A2B32",
                                primaryColorDark: "#061A22",
                                textColor: "#ffffff",
                                credits: [],
                                view: .tile,
                                sections: nil,
                                kind: .book)
        
        let resource1 = Resource(id: "youth-week-of-prayer-2022",
                                 index: "en/study/youth-week-of-prayer-2022",
                                 title: "The Present Truth: God's Message for Today",
                                 subtitle: "Youth Week of Prayer 2022",
                                 description: nil,
                                 cover: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/youth-week-of-prayer-2022/assets/img/cover.png"),
                                 tile: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/youth-week-of-prayer-2022/assets/img/tile.png"),
                                 splash: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/youth-week-of-prayer-2022/assets/img/splash.png"),
                                 primaryColor: "#1A2B32",
                                 primaryColorDark: "#061A22",
                                 textColor: "#ffffff",
                                 credits: [],
                                 view: .tile,
                                 sections: [],
                                 kind: .book)
        
        return ResourceGroup(type: "group",
                             title: "Youth Ministries",
                             cover: nil,
                             resources: [resource, resource1],
                             view: .tile)
    }
    
    static func generateResourceGroup() -> ResourceGroup {
        
        let resource = Resource(id: "bhp-bible-2022", index: "en/study/bhp-bible-2022", title: "Believe His Prophets Bible Reading", subtitle: "A five-year program reading through the Bible", description: nil, cover: nil, tile: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/bhp-bible-2022/assets/img/tile.png"), splash: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/bhp-bible-2022/assets/img/splash.png"), primaryColor: "#333333", primaryColorDark: "#000000", textColor: "#ffffff", credits: [], view: .tile, sections: nil, kind: .devotional)
        
        let resource1 = Resource(id: "bhp-ellen-white-2022", index: "en/study/bhp-ellen-white-2022", title: "Spirit of Prophecy Reading", subtitle: "2022. A five-year program reading through Spirit of Prophecy", description: nil, cover: nil, tile: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/bhp-ellen-white-2022/assets/img/tile.png"), splash: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/bhp-ellen-white-2022/assets/img/splash.png"), primaryColor: "#333333", primaryColorDark: "#000000", textColor: "#ffffff", credits: [], view: .tile, sections: nil, kind: .devotional)
        
        return ResourceGroup(type: "group",
                             title: "Revival and Reformation",
                             cover: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/assets/img/rr-cover.png"),
                             resources: [resource, resource1],
                             view: .list)
    }
    
    static func generateResourceViewModelList() -> [ResourceViewModel] {
        
        let resource0 = Resource(id: "discipleship-handbook",
                                index: "en/pm/discipleship-handbook",
                                title: "Discipleship Handbook",
                                subtitle: "A Resource for Seventh-day Adventist Church Members. The Discipleship Handbook is part of the GROW Your Church series of         Personal Ministries resources.",
                                description: nil,
                                cover: URL(string: "https://sabbath-school.adventech.io/api/v2/en/pm/discipleship-handbook/assets/img/cover.png"),
                                tile: nil,
                                splash: nil,
                                primaryColor: "#BD1F3E",
                                primaryColorDark: "#000000",
                                textColor: "#ffffff",
                                credits: nil,
                                view: .book,
                                sections: nil,
                                kind: .book)
        
        let resourceFeed = ResourceFeed.resourceGroup(ResourceGroup(type: "group", title: "Revival and Reformation", cover: URL(string: "https://sabbath-school.adventech.io/api/v2/en/study/assets/img/rr-cover.png"), resources: [], view: .list))

        return [
            ResourceViewModel(id: 0, resourceFeed: ResourceFeed.resource(resource0)),
            ResourceViewModel(id: 3, resourceFeed: resourceFeed)
        ]
    }
    
    static func generateResourceFeedViewModel() -> ResourceFeedViewModel {
        return ResourceFeedViewModel(items: generateResourceViewModelList())
    }
}
