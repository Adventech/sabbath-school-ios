//
//  Lesson.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import Unbox

struct Lesson {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let cover: URL?
    let index: String
    let path: String
    let fullPath: URL
}

extension Lesson: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        title = try unboxer.unbox(key: "title")
        startDate = try unboxer.unbox(key: "start_date", formatter: Date.serverDateFormatter())
        endDate = try unboxer.unbox(key: "end_date", formatter: Date.serverDateFormatter())
        index = try unboxer.unbox(key: "index")
        cover = unboxer.unbox(key: "cover")
        path = try unboxer.unbox(key: "path")
        fullPath = try unboxer.unbox(key: "full_path")
    }
}
