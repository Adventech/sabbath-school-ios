//
//  TextStyle.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-27.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

struct TextStyles {
    static func navBarTitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoBold(size: 15)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func navBarButtonStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoRegular(size: 15)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func menuTitleStyle(string: String, color: UIColor = .baseGray4) -> NSAttributedString {
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 16)!,
            NSForegroundColorAttributeName: color
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func menuSubtitleStyle(string: String, color: UIColor = .baseGray3) -> NSAttributedString {
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 13)!,
            NSForegroundColorAttributeName: color
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
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
    
    static func cellDetailStyle(string: String, color: UIColor = .baseGray2) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: R.font.latoMedium(size: 14)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func featuredQuarterlyTitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoBold(size: 30)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func featuredQuarterlyHumanDateStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7),
            NSFontAttributeName: R.font.latoRegular(size: 12)!
        ]
        return NSAttributedString(string: string.uppercased(), attributes: attributes)
    }
    
    static func featuredQuarterlyDescriptionStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7),
            NSFontAttributeName: R.font.latoRegular(size: 16)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func lessonInfoTitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoBold(size: 34)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func lessonInfoHumanDateStyle(string: String, color: UIColor = .baseGray2) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7),
            NSFontAttributeName: R.font.latoRegular(size: 12)!
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
    
    static func signInButtonTitleStyle(string: String, color: UIColor = .baseGray3) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: R.font.latoBold(size: 16)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func loginLogoTextStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGreen,
            NSFontAttributeName: R.font.latoBold(size: 26)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func profileUserNameStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray4,
            NSFontAttributeName: R.font.latoBold(size: 20)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func languageTitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray4,
            NSFontAttributeName: R.font.latoRegular(size: 17)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func languageSubtitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2,
            NSFontAttributeName: R.font.latoRegular(size: 13)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func readTitleStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoMediumItalic(size: 30)!,
            NSParagraphStyleAttributeName: style
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func readDateStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoItalic(size: 15)!,
            NSParagraphStyleAttributeName: style
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func settingsHeaderStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2,
            NSFontAttributeName: R.font.latoMedium(size: 12)!,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string.uppercased(), attributes: attributes)
    }
    
    static func settingsFooterCopyrightStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoItalic(size: 11)!,
            NSForegroundColorAttributeName: UIColor.baseGray4,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func settingsCellStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 16)!,
            NSForegroundColorAttributeName: UIColor.baseGray5,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func settingsCellDetailStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 15)!,
            NSForegroundColorAttributeName: UIColor.baseGray4,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
}
