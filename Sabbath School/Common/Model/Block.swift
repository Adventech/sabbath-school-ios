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

enum Block: Codable {
    case paragraph(Paragraph)
    case heading(Heading)
    case list(Block.List)
    case listItem(Block.ListItem)
    case hr(Hr)
    case reference(Reference)
    case question(Question)
    case blockquote(Blockquote)
    case collapse(Collapse)
    case image(Image)
    case unknown(Unknown)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKey.self)
         let type = try container.decode(String.self, forKey: .type)
         switch type {
         case "paragraph":
             self = try .paragraph(Paragraph(from: decoder))
         case "heading":
             self = try .heading(Heading(from: decoder))
         case "list":
             self = try .list(Block.List(from: decoder))
         case "list-item":
             self = try .listItem(Block.ListItem(from: decoder))
         case "reference":
             self = try .reference(Reference(from: decoder))
         case "question":
             self = try .question(Question(from: decoder))
         case "blockquote":
             self = try .blockquote(Blockquote(from: decoder))
         case "collapse":
             self = try .collapse(Collapse(from: decoder))
         case "image":
             self = try .image(Image(from: decoder))
         default:
             self = try .unknown(Unknown(from: decoder))
             
         }
    }
    
    enum TypeCodingKey: String, CodingKey {
        case type
    }
    
    enum ReferenceScope: String, Codable {
        case resource
        case document
    }
    
    struct Heading: Codable {
        let type: String
        let markdown: String
        let depth: Int
    }
    
    struct Paragraph: Codable {
        let type: String
        let markdown: String
    }
    
    struct List: Codable {
        let type: String
        let depth: Int?
        let ordered: Bool?
        let start: Int?
        let items: [Block]?
    }
    
    struct ListItem: Codable {
        let type: String
        let markdown: String
    }
    
    struct Hr: Codable {
        let type: String
    }
    
    struct Reference: Codable {
        let type: String
        let target: String
        let scope: ReferenceScope
        let title: String
        let subtitle: String?
    }
    
    struct Question: Codable  {
        let type: String
        let markdown: String
    }
    
    struct Blockquote: Codable {
        let type: String
        let memoryVerse: Bool?
        let citation: Bool?
        let caption: String?
        let items: [Block]
    }
    
    struct Collapse: Codable {
        let type: String
        let caption: String
        let items: [Block]
    }
    
    struct Image: Codable {
        let type: String
        let src: URL
        let caption: String?
    }
    
    struct Unknown: Codable {
        let type: String
    }
}
