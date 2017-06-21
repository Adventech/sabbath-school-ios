/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
            NSFontAttributeName: R.font.latoMedium(size: 18)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func cellSubtitleStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2,
            NSFontAttributeName: R.font.latoRegular(size: 16)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func cellDetailStyle(string: String, color: UIColor = .baseGray2) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: R.font.latoMedium(size: 15)!
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
    
    static func featuredQuarterlyDescriptionStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7),
            NSFontAttributeName: R.font.latoRegular(size: 16)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func cellLessonNumberStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2.withAlphaComponent(0.5),
            NSFontAttributeName: R.font.latoBold(size: 22)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func readButtonStyle(string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: R.font.latoBold(size: 15)!
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
    
    static func settingsFooterStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.baseGray2,
            NSFontAttributeName: R.font.latoMedium(size: 12)!,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    
    static func settingsFooterCopyrightStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 11)!,
            NSForegroundColorAttributeName: UIColor.baseGray2,
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
    
    static func settingsDestructiveCellStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 16)!,
            NSForegroundColorAttributeName: UIColor.baseRed,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func settingsCellDetailStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 15)!,
            NSForegroundColorAttributeName: UIColor.baseGray2,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func sloganStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 15)!,
            NSForegroundColorAttributeName: UIColor.baseGray3,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func websiteUrlStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 18)!,
            NSForegroundColorAttributeName: UIColor.tintColor,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func descriptionStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineSpacing = 6
        
        let attributes = [
            NSFontAttributeName: R.font.latoRegular(size: 18)!,
            NSForegroundColorAttributeName: UIColor.baseGray3,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static func signatureStyle(string: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let attributes = [
            NSFontAttributeName: R.font.latoBold(size: 18)!,
            NSForegroundColorAttributeName: UIColor.baseGray3,
            NSParagraphStyleAttributeName: style
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }

    // MARK: Headers

    static func h1(string: String, color: UIColor = .white) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: R.font.latoBold(size: 36)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }

    static func h2(string: String, color: UIColor = .white) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: R.font.latoBold(size: 30)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }

    static func h3(string: String, color: UIColor = .baseGray3) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: R.font.latoBold(size: 24)!
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }

    static func uppercaseHeader(string: String, color: UIColor = UIColor.white.withAlphaComponent(0.7)) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: R.font.latoBold(size: 13)!
        ]
        return NSAttributedString(string: string.uppercased(), attributes: attributes)
    }
}
