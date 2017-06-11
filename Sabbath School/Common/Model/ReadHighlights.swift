//
//  ReadHighlights.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct ReadHighlights {
    let readIndex: String
    let highlights: String
}

extension ReadHighlights: Unboxable {
    init(unboxer: Unboxer) throws {
        readIndex = try unboxer.unbox(key: "readIndex")
        highlights = try unboxer.unbox(key: "highlights")
    }
}
