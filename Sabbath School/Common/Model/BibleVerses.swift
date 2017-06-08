//
//  BibleVerses.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-01.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct BibleVerses {
    let name: String
    let verses: [String: String]
}

extension BibleVerses: Unboxable {
    init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "name")
        verses = try unboxer.unbox(key: "verses")
    }
}
