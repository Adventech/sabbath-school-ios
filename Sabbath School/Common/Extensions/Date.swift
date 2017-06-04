//
//  Date.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

extension Date {
    
    /**
     Convert date from server Format
     */
    public static func serverDateFormatter() -> DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        format.locale = Locale.ReferenceType.current
        format.calendar = Calendar.ReferenceType.current
        return format
    }
    
    func stringLessonDate() -> String {
        let format = DateFormatter()
        format.dateFormat = "MMM dd"
        format.locale = Locale.ReferenceType.current
        format.calendar = Calendar.ReferenceType.current
        return format.string(from: self)
    }
}
