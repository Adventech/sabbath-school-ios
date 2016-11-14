//
//  BibleVerses.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 28/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
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
