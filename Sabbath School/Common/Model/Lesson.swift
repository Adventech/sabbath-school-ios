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

struct Lesson: Codable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let cover: URL?
    let index: String
    let path: String
    let fullPath: URL
    let pdfOnly: Bool
    var dateRange: String = ""
    var webURL: URL
    
    enum CodingKeys: CodingKey {
      case id, title, startDate, endDate, cover, index, path, fullPath, pdfOnly, dateRange, webURL
    }
    
    // Mock
    init(title: String) {
        self.id = "1"
        self.title = title
        self.startDate = Date()
        self.endDate = Date()
        self.cover = URL.init(string: "https://adventech.io")!
        self.index = "-"
        self.path = "-"
        self.fullPath = URL.init(string: "https://adventech.io")!
        self.webURL = URL.init(string: "https://adventech.io")!
        self.pdfOnly = false
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        startDate = Date.serverDateFormatter().date(from: try values.decode(String.self, forKey: .startDate))!
        endDate = Date.serverDateFormatter().date(from: try values.decode(String.self, forKey: .endDate))!
        cover = try values.decode(URL.self, forKey: .cover)
        index = try values.decode(String.self, forKey: .index)
        path = try values.decode(String.self, forKey: .path)
        fullPath = try values.decode(URL.self, forKey: .fullPath)
        dateRange = String(format: "%@ - %@", startDate.stringLessonDate(), endDate.stringLessonDate())
        webURL = URL.init(string: String(format: "%@/01", fullPath.absoluteString.replacingOccurrences(of: Constants.URLs.webReplacementRegex, with: "", options: [.regularExpression])))!
        pdfOnly = try values.decode(Bool.self, forKey: .pdfOnly)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(Date.serverDateFormatter().string(from: startDate), forKey: .startDate)
        try container.encode(Date.serverDateFormatter().string(from: endDate), forKey: .endDate)
        try container.encode(cover, forKey: .cover)
        try container.encode(index, forKey: .index)
        try container.encode(path, forKey: .path)
        try container.encode(fullPath, forKey: .fullPath)
        try container.encode(dateRange, forKey: .dateRange)
        try container.encode(webURL, forKey: .webURL)
        try container.encode(pdfOnly, forKey: .pdfOnly)
    }
}
