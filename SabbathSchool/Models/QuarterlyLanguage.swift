//
//  QuarterlyLanguage.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import Unbox

struct QuarterlyLanguage {
    let code: String
    let name: String
}

extension QuarterlyLanguage: Unboxable {
    init(unboxer: Unboxer) throws {
        code = try unboxer.unbox(key: "code")
        name = try unboxer.unbox(key: "language")
    }
}
