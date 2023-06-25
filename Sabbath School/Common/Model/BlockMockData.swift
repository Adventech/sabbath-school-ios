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
}
