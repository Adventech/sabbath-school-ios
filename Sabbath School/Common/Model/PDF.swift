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

struct PDF: Codable {
    let id: String
    let src: URL
    let title: String
    let target: String
    let startDate: Date
    let endDate: Date
    
    // Mock
    init(title: String) {
        self.id = "en-2021-03-13"
        self.src = URL.init(string: "https://www.gracelink.net/assets/gracelink/Lessons/Primary/2021/Q3/Primary/Student/P-21-Q3-L01.pdf")!
        self.title = title
        self.target = "en-2021-03-12"
        self.startDate = Date()
        self.endDate = Date()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        src = try values.decode(URL.self, forKey: .src)
        title = try values.decode(String.self, forKey: .title)
        target = try values.decode(String.self, forKey: .target)
        startDate = Date.serverDateFormatter().date(from: try values.decode(String.self, forKey: .startDate))!
        endDate = Date.serverDateFormatter().date(from: try values.decode(String.self, forKey: .endDate))!
    }
}
