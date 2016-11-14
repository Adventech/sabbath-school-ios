//
//  Array.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 13/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import Foundation

extension Array {
    
    /**
     Return index if is safe, if not return nil
     http://stackoverflow.com/a/30593673/517707
     */
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
