//
//  QuarterlyInfo.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

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
