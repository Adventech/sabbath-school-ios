//
//  LessonInfo.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-01.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct LessonInfo {
    let lesson: Lesson
    let days: [Day]
}

extension LessonInfo: Unboxable {
    init(unboxer: Unboxer) throws {
        lesson = try unboxer.unbox(key: "lesson")
        days = try unboxer.unbox(key: "days")
    }
}
