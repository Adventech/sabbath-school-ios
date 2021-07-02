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
    let colorPrimary: String?
    let colorPrimaryDark: String?
    let index: String
    let path: String
    let fullPath: URL
    let lang: String
    let webURL: URL
    let quarterlyName: String?
    
    // Mock
    init(title: String) {
        self.id = "-"
        self.title = title
        self.description = "-"
        self.humanDate = "-"
        self.startDate = Date()
        self.endDate = Date()
        self.cover = URL.init(string: "https://adventech.io")!
        self.colorPrimary = "-"
        self.colorPrimaryDark = "-"
        self.index = "-"
        self.path = "-"
        self.fullPath = URL.init(string: "https://adventech.io")!
        self.lang = "-"
        self.webURL = URL.init(string: "https://adventech.io")!
        self.quarterlyName = "-"
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
        colorPrimary = try values.decode(String.self, forKey: .colorPrimary)
        colorPrimaryDark = try values.decode(String.self, forKey: .colorPrimaryDark)
        index = try values.decode(String.self, forKey: .index)
        path = try values.decode(String.self, forKey: .path)
        fullPath = try values.decode(URL.self, forKey: .fullPath)
        lang = try values.decode(String.self, forKey: .lang)
        webURL = URL.init(string: fullPath.absoluteString.replacingOccurrences(of: Constants.URLs.webReplacementRegex, with: "", options: [.regularExpression]))!
        quarterlyName = values.contains(.quarterlyName) ? try values.decode(String.self, forKey: .quarterlyName) : nil
    }
}
