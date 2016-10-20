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
    let content: String
    let verses: [String]
}

extension Read: Unboxable {
    init(unboxer: Unboxer) throws {
        content = try unboxer.unbox(key: "content")
        verses = try unboxer.unbox(key: "verses")
    }
}
