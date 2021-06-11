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
    var dateRange: String = ""
    var webURL: URL
    
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
    }
}
