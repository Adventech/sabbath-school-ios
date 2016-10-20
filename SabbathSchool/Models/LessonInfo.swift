//
//  LessonInfo.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
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
