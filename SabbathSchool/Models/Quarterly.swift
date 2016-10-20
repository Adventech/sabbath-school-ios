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
    let date: String
    let cover: String
    let index: String
    let path: String
    let fullPath: String
    let lang: String
}

extension Quarterly: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        title = try unboxer.unbox(key: "title")
        description = try unboxer.unbox(key: "description")
        date = try unboxer.unbox(key: "date")
        cover = try unboxer.unbox(key: "cover")
        index = try unboxer.unbox(key: "index")
        path = try unboxer.unbox(key: "path")
        fullPath = try unboxer.unbox(key: "full_path")
        lang = try unboxer.unbox(key: "lang")
    }
}
