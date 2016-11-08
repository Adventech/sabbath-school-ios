//
//  Quarterly.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import Unbox

struct Quarterly {
    let id: String
    let title: String
    let description: String
    let humanDate: String
    let startDate: Date
    let endDate: Date
    let cover: URL
    let colorPrimary: String?
    let colorPrimaryDark: String?
    let index: String
    let path: String
    let fullPath: URL
    let lang: String
}

extension Quarterly: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        title = try unboxer.unbox(key: "title")
        description = try unboxer.unbox(key: "description")
        humanDate = try unboxer.unbox(key: "human_date")
        startDate = try unboxer.unbox(key: "start_date", formatter: Date.serverDateFormatter())
        endDate = try unboxer.unbox(key: "end_date", formatter: Date.serverDateFormatter())
        cover = try unboxer.unbox(key: "cover")
        colorPrimary = unboxer.unbox(key: "color_primary")
        colorPrimaryDark = unboxer.unbox(key: "color_primary_dark")
        index = try unboxer.unbox(key: "index")
        path = try unboxer.unbox(key: "path")
        fullPath = try unboxer.unbox(key: "full_path")
        lang = try unboxer.unbox(key: "lang")
    }
}
