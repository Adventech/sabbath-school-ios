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

enum ShareGroupType: String, Codable {
    case link
    case file
}

struct ShareLinkURL: Codable {
    let title: String?
    let src: URL
}

struct ShareFileURL: Codable {
    let title: String?
    let fileName: String?
    let src: URL
}

struct ShareGroup: Codable {
    let type: ShareGroupType
}

struct ShareGroupLink: ShareGroupProtocol {
    let type: ShareGroupType
    let title: String
    let links: [ShareLinkURL]
    let selected: Bool?
}

struct ShareGroupFile: ShareGroupProtocol {
    let type: ShareGroupType
    let title: String
    let files: [ShareFileURL]
    let selected: Bool?
}

protocol ShareGroupProtocol: Codable {
    var type: ShareGroupType { get }
    var title: String { get }
    var selected: Bool? { get }
}

struct AnyShareGroup: Codable {
    private let _base: any ShareGroupProtocol
    
    var type: ShareGroupType {
        return _base.type
    }
    
    var title: String {
        return _base.title
    }
    
    var selected: Bool? {
        return _base.selected
    }
    
    init(_ base: any ShareGroupProtocol) {
        self._base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try _base.encode(to: encoder)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ShareGroupType.self, forKey: .type)

        switch type {
        case .link:
            _base = try ShareGroupLink(from: decoder)
        case .file:
            _base = try ShareGroupFile(from: decoder)
        }
    }
    
    func asType<T: ShareGroupProtocol>(_ type: T.Type) -> T? {
        return _base as? T
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}

struct ShareOptions: Codable {
    let shareGroups: [AnyShareGroup]
    let shareText: String
    let shareCTA: Bool?
    let personalize: Bool?
}
