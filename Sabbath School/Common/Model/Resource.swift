/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
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

struct ResourceInfo: Codable, Hashable {
    let name: String
    let code: String
    let aij: Bool
    let pm: Bool
    let devo: Bool
    let ss: Bool
    let explore: Bool
    
    var translatedName: String? = ""
    
    init(code: String, name: String, ss: Bool, aij: Bool, pm: Bool, devo: Bool, explore: Bool) {
        self.code = code
        self.name = name
        self.ss = ss
        self.aij = aij
        self.pm = pm
        self.devo = devo
        self.explore = explore

        self.translatedName = Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? name.capitalized
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try values.decode(String.self, forKey: .name)
        self.code = try values.decode(String.self, forKey: .code)
        
        self.ss = try values.decode(Bool.self, forKey: .ss)
        self.aij = try values.decode(Bool.self, forKey: .aij)
        self.pm = try values.decode(Bool.self, forKey: .pm)
        self.devo = try values.decode(Bool.self, forKey: .devo)
        self.explore = try values.decode(Bool.self, forKey: .explore)
        
        self.translatedName = Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? name.capitalized
    }
}

enum ResourceType: String, Codable {
    case pm
    case devo
    case aij
    case ss
    case explore
    case authors
    case categories
}

enum ResourceCoverType: Codable {
    case landscape
    case portrait
    case splash
    case square
    
    var aspectRatio: CGFloat {
        switch self {
        case .landscape: return 1280/720
        case .square: return 1
        case .portrait: return 854/1280
        case .splash: return 1
        }
    }
}

enum ResourcePreferredCover: String, Codable {
    case landscape
    case portrait
    case square
}

enum ResourceKind: String, Codable {
    case book
    case devotional
    case plan
    case external
    case blog
    case magazine
}

struct ResourceFont: Codable {
    let name: String
    let weight: Int
    let src: URL
}

struct ResourceCredit: Codable {
    let name: String
    let value: String
}

struct ResourceFeature: Codable {
    let name: String
    let title: String
    let description: String
    let image: URL
}

struct ResourceCovers: Codable {
    let square: URL
    let splash: URL?
    let landscape: URL
    let portrait: URL
}

struct ResourceCTA: Codable {
    let hidden: Bool?
    let text: String?
}

enum ProgressTracking: String, Codable {
    case none
    case automatic
    case manual
}

struct Resource: Codable, Identifiable {
    let id: String
    let index: String
    let title: String
    let markdownTitle: String?
    let subtitle: String?
    let markdownSubtitle: String?
    let description: String?
    let markdownDescription: String?
    let introduction: String?
    let primaryColor: String
    let primaryColorDark: String
    let sections: [ResourceSection]?
    let sectionView: ResourceSectionViewType?
    let feeds: [AnyFeedGroup]?
    let kind: ResourceKind
    let covers: ResourceCovers
    let features: [ResourceFeature]
    let credits: [ResourceCredit]
    let fonts: [ResourceFont]?
    let style: Style?
    let externalURL: URL?
    let cta: ResourceCTA?
    let preferredCover: ResourcePreferredCover?
    let progressTracking: ProgressTracking?
    let displayProgress: Bool?
    let authors: [Author]?
    let type: ResourceType?
    let displayCoversInTableOfContents: Bool?
    let documentId: String?
    let documentIndex: String?
    let downloadable: Bool?
}
