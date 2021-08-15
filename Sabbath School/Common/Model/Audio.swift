/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

struct Audio: Codable {
    let id: String
    let target: String
    let targetIndex: String
    let title: String
    let artist: String
    let src: URL
    let image: URL
    let imageRatio: String
    
    init(title: String, artist: String, image: String? = nil, src: String? = nil) {
        self.title = title
        self.artist = artist
        self.id = "unique-id"
        self.target = "year-quarter/week"
        self.targetIndex = "year-quarter-week"
        self.image = URL.init(string: image ?? "https://sabbath-school-stage.adventech.io/api/v1/ru/quarterlies/2021-03/cover.png")!
        self.src = URL.init(string: src ?? "https://s3.amazonaws.com/kargopolov/kukushka.mp3")!
        self.imageRatio = "square"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        target = try values.decode(String.self, forKey: .target)
        targetIndex = try values.decode(String.self, forKey: .targetIndex)
        title = try values.decode(String.self, forKey: .title)
        artist = try values.decode(String.self, forKey: .artist)
        src = try values.decode(URL.self, forKey: .src)
        image = try values.decode(URL.self, forKey: .image)
        imageRatio = try values.decode(String.self, forKey: .imageRatio)
    }
}
