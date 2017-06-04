//
//  Comment.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct Comment {
    let elementId: String
    let comment: String
}

extension Comment: Unboxable {
    init(unboxer: Unboxer) throws {
        elementId = try unboxer.unbox(key: "elementId")
        comment = try unboxer.unbox(key: "comment")
    }
}
