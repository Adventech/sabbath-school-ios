//
//  Date.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 21/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

extension Date {
    
    /**
     Convert date from server Format
     */
    public static func serverDateFormatter() -> DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        return format
    }
    
    func stringLessonDate() -> String {
        let format = DateFormatter()
        format.dateFormat = "MMM dd"
        return format.string(from: self)
    }
}
