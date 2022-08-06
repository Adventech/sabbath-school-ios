/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
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

struct Quarterly: Codable {
    static func ==(lhs: Quarterly, rhs: Quarterly) -> Bool {
        return lhs.id == rhs.id && lhs.index == rhs.index
    }
    
    let id: String
    let title: String
    let description: String
    let humanDate: String
    let startDate: Date
    let endDate: Date
    let cover: URL
    let splash: URL?
    let colorPrimary: String?
    let colorPrimaryDark: String?
    let index: String
    let path: String
    let fullPath: URL
    let lang: String
    let webURL: URL
    let quarterlyName: String?
    let introduction: String
    let credits: [Credits]
    let features: [Feature]
    let quarterlyGroup: QuarterlyGroup?
    
    enum CodingKeys: CodingKey {
      case id, title, description, humanDate, startDate, endDate, cover, splash, colorPrimary, colorPrimaryDark, index, path, fullPath, lang, webURL, quarterlyName, introduction, credits, features, quarterlyGroup
    }
    
    // Mock
    init(title: String) {
        self.id = "-"
        self.title = title
        self.description = "-"
        self.humanDate = "-"
        self.startDate = Date()
        self.endDate = Date()
        self.cover = URL.init(string: "https://sabbath-school-stage.adventech.io/api/v1/ru/quarterlies/2021-03/cover.png")!
        self.splash = URL.init(string: "https://adventech.io")!
        self.colorPrimary = "-"
        self.colorPrimaryDark = "-"
        self.index = "-"
        self.path = "-"
        self.fullPath = URL.init(string: "https://adventech.io")!
        self.lang = "-"
        self.webURL = URL.init(string: "https://adventech.io")!
        self.quarterlyName = "-"
        self.introduction = "-"
        self.credits = Array<Credits>()
        self.features = Array<Feature>()
        self.quarterlyGroup = nil
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        humanDate = try values.decode(String.self, forKey: .humanDate)
        startDate = Date.serverDateFormatter().date(from: try values.decode(String.self, forKey: .startDate))!
        endDate = Date.serverDateFormatter().date(from: try values.decode(String.self, forKey: .endDate))!
        cover = try values.decode(URL.self, forKey: .cover)
        splash = values.contains(.splash) ? try values.decode(URL.self, forKey: .splash) : nil
        colorPrimary = try values.decode(String.self, forKey: .colorPrimary)
        colorPrimaryDark = try values.decode(String.self, forKey: .colorPrimaryDark)
        index = try values.decode(String.self, forKey: .index)
        path = try values.decode(String.self, forKey: .path)
        fullPath = try values.decode(URL.self, forKey: .fullPath)
        lang = try values.decode(String.self, forKey: .lang)
        webURL = URL.init(string: fullPath.absoluteString.replacingOccurrences(of: Constants.URLs.webReplacementRegex, with: "", options: [.regularExpression]))!
        quarterlyName = values.contains(.quarterlyName) ? try values.decode(String.self, forKey: .quarterlyName) : nil
        introduction = values.contains(.introduction) ? try values.decode(String.self, forKey: .introduction) : description
        credits = values.contains(.credits) ? try values.decode(Array<Credits>.self, forKey: .credits) : Array<Credits>()
        features = values.contains(.features) ? try values.decode(Array<Feature>.self, forKey: .features) : Array<Feature>()
        quarterlyGroup = values.contains(.quarterlyGroup) ? try values.decode(QuarterlyGroup.self, forKey: .quarterlyGroup) : nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(humanDate, forKey: .humanDate)
        try container.encode(Date.serverDateFormatter().string(from: startDate), forKey: .startDate)
        try container.encode(Date.serverDateFormatter().string(from: endDate), forKey: .endDate)
        try container.encode(cover, forKey: .cover)
        if splash != nil {
            try container.encode(splash, forKey: .splash)
        }
        try container.encode(colorPrimary, forKey: .colorPrimary)
        try container.encode(colorPrimaryDark, forKey: .colorPrimaryDark)
        try container.encode(index, forKey: .index)
        try container.encode(path, forKey: .path)
        try container.encode(fullPath, forKey: .fullPath)
        try container.encode(lang, forKey: .lang)
        try container.encode(webURL, forKey: .webURL)
        try container.encode(quarterlyName ?? "", forKey: .quarterlyName)
        try container.encode(introduction, forKey: .introduction)
        try container.encode(credits, forKey: .credits)
        try container.encode(features, forKey: .features)
        if quarterlyGroup != nil {
            try container.encode(quarterlyGroup, forKey: .quarterlyGroup)
        }
        
    }
}

struct QuarterlyCache: Codable, Comparable {
    let quarterlies: [Quarterly]?
}
