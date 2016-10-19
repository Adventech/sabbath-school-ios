//
//  TextStyles.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

struct TextStyles {
    
    // MARK: - Navigation bars
    
    static func navBarTitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoMedium(size: 17)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    // MARK: - Quarter
    
    static func cellTitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray3,
            NSFontAttributeName: R.font.latoMedium(size: 17)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func cellSubtitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2,
            NSFontAttributeName: R.font.latoItalic(size: 16)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func cellDetailStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2,
            NSFontAttributeName: R.font.latoMedium(size: 14)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func currentQuarterTitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoBold(size: 20)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func currentQuarterSubtitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7),
            NSFontAttributeName: R.font.latoItalic(size: 16)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func cellLessonNumberStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2.withAlphaComponent(0.5),
            NSFontAttributeName: R.font.latoRegular(size: 22)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func readButtonStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoRegular(size: 16)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
}
