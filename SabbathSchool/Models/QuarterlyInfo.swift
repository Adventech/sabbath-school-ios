//
//  QuarterlyInfo.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import Unbox

struct QuarterlyInfo {
    let quarterly: Quarterly
    let lessons: [Lesson]
}

extension QuarterlyInfo: Unboxable {
    init(unboxer: Unboxer) throws {
        quarterly = try unboxer.unbox(key: "quarterly")
        lessons = try unboxer.unbox(key: "lessons")
    }
}
