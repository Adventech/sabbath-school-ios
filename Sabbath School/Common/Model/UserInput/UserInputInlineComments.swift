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

struct UserInputInlineComment: Codable, Equatable, Hashable {
    let id: String
    let startIndex: Int
    let endIndex: Int
    let length: Int
    var color: HighlightColor
    var comment: String
    
    static func ==(lhs: UserInputInlineComment, rhs: UserInputInlineComment) -> Bool {
        return lhs.startIndex == rhs.startIndex &&
               lhs.endIndex == rhs.endIndex &&
               lhs.length == rhs.length &&
               lhs.color == rhs.color
    }
    
    init(
        id: String = UUID().uuidString.lowercased(),
        startIndex: Int,
        endIndex: Int,
        length: Int,
        color: HighlightColor,
        comment: String
    ) {
        self.id = id
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.length = length
        self.color = color
        self.comment = comment
    }
}

struct UserInputInlineComments: UserInputProtocol {
    let blockId: String
    let inputType: UserInputType
    let inlineComments: [UserInputInlineComment]
    let timestamp: Int
}
