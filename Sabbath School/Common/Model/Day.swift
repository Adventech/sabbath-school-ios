//
//  Day.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct Day {
    let id: String
    let title: String
    let date: Date
    let index: String
    let path: String
    let readPath: String
    let fullPath: URL
    let fullReadPath: URL
}

extension Day: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        title = try unboxer.unbox(key: "title")
        date = try unboxer.unbox(key: "date", formatter: Date.serverDateFormatter())
        index = try unboxer.unbox(key: "index")
        path = try unboxer.unbox(key: "path")
        readPath = try unboxer.unbox(key: "read_path")
        fullPath = try unboxer.unbox(key: "full_path")
        fullReadPath = try unboxer.unbox(key: "full_read_path")
    }
}
