//
//  Day.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import Unbox

struct Day {
    let id: String
    let title: String
    let date: String
    let index: String
    let path: String
    let fullPath: String
    let readPath: String
    let fullReadPath: String
}

extension Day: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        title = try unboxer.unbox(key: "title")
        date = try unboxer.unbox(key: "date")
        index = try unboxer.unbox(key: "index")
        path = try unboxer.unbox(key: "path")
        fullPath = try unboxer.unbox(key: "full_path")
        readPath = try unboxer.unbox(key: "read_path")
        fullReadPath = try unboxer.unbox(key: "full_read_path")
    }
}
