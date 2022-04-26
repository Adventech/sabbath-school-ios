//
//  Comparable.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 23/04/22.
//  Copyright © 2022 Adventech. All rights reserved.
//

import Foundation

protocol Comparable: Codable {
    func isEqual(from other: Self) -> Bool
}

extension Comparable {
    func isEqual(from other: Self) -> Bool {
        return self.jsonData == other.jsonData
    }
}
