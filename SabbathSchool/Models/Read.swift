//
//  Read.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
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
