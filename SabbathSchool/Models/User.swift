//
//  User.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 20/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import Unbox

struct User {
    let name: String
    let email: String
    let photo: String
}

extension User: Unboxable {
    init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "name")
        email = try unboxer.unbox(key: "email")
        photo = try unboxer.unbox(key: "photo")
    }
}
