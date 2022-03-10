//
//  Array.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 10/03/22.
//  Copyright © 2022 Adventech. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
