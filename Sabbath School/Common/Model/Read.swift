//
//  Read.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct Read {
    let id: String
    let date: Date
    let index: String
    let title: String
    let content: String
    let bible: [BibleVerses]
}

extension Read: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        date = try unboxer.unbox(key: "date", formatter: Date.serverDateFormatter())
        index = try unboxer.unbox(key: "index")
        title = try unboxer.unbox(key: "title")
        content = try unboxer.unbox(key: "content")
        bible = unboxer.unbox(key: "bible") ?? []
    }
}
