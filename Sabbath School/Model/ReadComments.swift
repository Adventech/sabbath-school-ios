//
//  ReadComments.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct ReadComments {
    let readIndex: String
    let comments: [Comment]
}

extension ReadComments: Unboxable {
    init(unboxer: Unboxer) throws {
        readIndex = try unboxer.unbox(key: "readIndex")
        comments = try unboxer.unbox(key: "comments")
    }
}
