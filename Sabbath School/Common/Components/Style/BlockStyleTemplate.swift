/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
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

import SwiftUI

class BlockStyleTemplate: StyleTemplate {
    var textKeyPath: KeyPath<Style, TextStyle?>
    var blockStyleKeyPath: KeyPath<Style, BlockStyle?>
    
    var textSizeEnabled: Bool
    var textSizeDefault: CGFloat
    var textSizePoints: (_ size: TextStyleSize) -> CGFloat
    
    var textColorEnabled: Bool
    var textColorDefault: Color
    
    var textTypefaceEnabled: Bool
    var textTypefaceDefault: String
    
    var textAlignmentEnabled: Bool
    var textAlignmentDefault: TextAlignment
    var textAlignmentFunc: (_ alignment: TextStyleAlignment) -> TextAlignment
    
    var textOffsetEnabled: Bool
    var textOffsetDefault: CGFloat
    var textOffsetFunc: (TextStyleOffset) -> CGFloat
    
    var textColorThemeOverride: Bool
    var textLinksEnabled: Bool
    
    var textInlineStyleEnabled: Bool
    
    var paddingEnabled: Bool
    var paddingDefault: EdgeInsets
    var paddingFunc: (BlockStyleSpacing) -> CGFloat
    
    var backgroundColorEnabled: Bool
    var backgroundColorDefault: Color
    
    var backgroundImageEnabled: Bool
    var backgroundImageDefault: URL?
    
    var roundedCornersEnabled: Bool
    var roundedCornersDefault: CGFloat
    var roundedCornersEnabledValue: CGFloat

    init () {
        let theme = ThemeManager()
        
        self.textKeyPath = \.blocks?.inline?.all?.text
        self.blockStyleKeyPath = \.blocks?.inline?.all
        
        self.textSizeEnabled = true
        
        
        self.textColorEnabled = true
        self.textColorDefault = theme.getTextColor()
        
        self.textTypefaceEnabled = true
        
        switch theme.currentTypeface {
        case .andada:
            self.textTypefaceDefault = "Lora-Regular"
        case .ptSans:
            self.textTypefaceDefault = "PTSans-Regular"
        case .ptSerif:
            self.textTypefaceDefault = "PTSerif-Regular"
        default:
            self.textTypefaceDefault = "Lato-Regular"
        }
        
//        if (theme.currentTheme == .dark || theme.currentTheme == .sepia || (theme.currentTheme == .auto && Preferences.darkModeEnable()))
//            {
//            self.textColorDefault = .white
//        }
        
        self.textAlignmentEnabled = true
        self.textAlignmentDefault = .leading
        self.textAlignmentFunc = { alignment in
            let alignmentMatrix: [TextStyleAlignment: TextAlignment] = [
                .start: .leading,
                .end: .trailing,
                .center: .center
            ]
            return alignmentMatrix[alignment] ?? .leading
        }
        
        self.textOffsetEnabled = true
        self.textOffsetDefault = 0.0
        self.textOffsetFunc = { offset in
            return offset == .sup ? 6 : -6
        }
        
        self.textColorThemeOverride = true
        self.textLinksEnabled = true
        
        self.textInlineStyleEnabled = true
        
        self.textSizePoints = { size in
            let sizeMatrix: [ReaderStyle.Size: [TextStyleSize: CGFloat]] = [
                .tiny: [
                    .xs: 14,
                    .sm: 15,
                    .base: 17,
                    .lg: 18,
                    .xl: 21,
                ],
                
                .small: [
                    .xs: 15,
                    .sm: 17,
                    .base: 18,
                    .lg: 21,
                    .xl: 24,
                ],
                
                .medium: [
                    .xs: 17,
                    .sm: 18,
                    .base: 21,
                    .lg: 24,
                    .xl: 26,
                ],
                
                .large: [
                    .xs: 18,
                    .sm: 21,
                    .base: 24,
                    .lg: 26,
                    .xl: 28,
                ],
                
                .huge: [
                    .xs: 21,
                    .sm: 24,
                    .base: 26,
                    .lg: 28,
                    .xl: 30,
                ]
            ]
            
            return sizeMatrix[theme.currentSize]?[size] ?? 21
        }
        
        self.textSizeDefault = self.textSizePoints(.base)
        
//        if (theme.currentTheme == .dark || theme.currentTheme == .sepia || (theme.currentTheme == .auto && Preferences.darkModeEnable()))
//            {
//            self.textColorDefault = .white
//        }
        
        self.textColorDefault = theme.getTextColor()
        
        self.paddingEnabled = true
        self.paddingDefault = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        self.paddingFunc = { spacing in
            switch spacing {
            case .none:
                return 0
            case .base:
                return 20
            case .xs:
                return 5
            case .sm:
                return 10
            case .lg:
                return 30
            case .xl:
                return 40
            }
        }
        
        self.backgroundColorEnabled = true
        self.backgroundColorDefault = .clear
        
        self.backgroundImageEnabled = true
        self.backgroundImageDefault = nil
        
        self.roundedCornersEnabled = true
        self.roundedCornersDefault = 0
        self.roundedCornersEnabledValue = 6.0
    }
}

class EmbeddedBlockStyleTemplate: BlockStyleTemplate {
    override init () {
        super.init()
        self.textLinksEnabled = false
    }
}

class HeadingStyleTemplate: BlockStyleTemplate {
    init (depth: HeadingDepth) {
        super.init()
        let theme = ThemeManager()
        
        switch theme.currentTypeface {
        case .andada:
            self.textTypefaceDefault = "Lora-Bold"
        case .ptSans:
            self.textTypefaceDefault = "PTSans-Bold"
        case .ptSerif:
            self.textTypefaceDefault = "PTSerif-Bold"
        default:
            self.textTypefaceDefault = "Lato-Bold"
        }
        
        self.textSizePoints = { size in
            let sizeMatrix: [ReaderStyle.Size: [HeadingDepth: CGFloat]] = [
                .tiny: [
                    .one: 24,
                    .two: 20,
                    .three: 17,
                    .four: 15,
                    .five: 13,
                    .six: 12
                ],
                
                .small: [
                    .one: 28,
                    .two: 24,
                    .three: 20,
                    .four: 17,
                    .five: 15,
                    .six: 13
                ],
                
                .medium: [
                    .one: 34,
                    .two: 28,
                    .three: 24,
                    .four: 20,
                    .five: 17,
                    .six: 15
                ],
                
                .large: [
                    .one: 37,
                    .two: 34,
                    .three: 28,
                    .four: 24,
                    .five: 20,
                    .six: 17
                ],
                
                .huge: [
                    .one: 42,
                    .two: 38,
                    .three: 34,
                    .four: 30,
                    .five: 24,
                    .six: 20
                ]
            ]
            
            return sizeMatrix[theme.currentSize]?[depth] ?? 34
        }
        
        self.textSizeDefault = self.textSizePoints(.base)
    }
}

class StoryStyleTemplate: BlockStyleTemplate {
    override init() {
        super.init()
        
        self.textTypefaceDefault = "Lato-Bold"
        self.textSizePoints = { size in
            return 28.0
        }
        self.textColorDefault = .white
        self.textColorThemeOverride = false
        self.textSizeDefault = self.textSizePoints(.base)
    }
}

class AppealStyleTemplate: BlockStyleTemplate {
    override init() {
        super.init()
        let theme = ThemeManager()
        self.textColorDefault = theme.getSecondaryTextColor()
    }
}
