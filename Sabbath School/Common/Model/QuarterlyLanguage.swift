//
//  QuarterlyLanguage.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

struct QuarterlyLanguage {
    let code: String
    let name: String
}

extension QuarterlyLanguage: Unboxable {
    init(unboxer: Unboxer) throws {
        code = try unboxer.unbox(key: "code")
        name = try unboxer.unbox(key: "name")
    }
}
