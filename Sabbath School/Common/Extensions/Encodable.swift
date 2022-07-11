//
//  Encodable.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 23/04/22.
//  Copyright © 2022 Adventech. All rights reserved.
//

import Foundation

extension Encodable {
    public var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }
}
