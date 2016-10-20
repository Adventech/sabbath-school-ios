//
//  DayComments.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import Unbox

struct DayComments {
    let comments: [String]
}

extension DayComments: Unboxable {
    init(unboxer: Unboxer) throws {
        comments = try unboxer.unbox(key: "comments")
    }
}
