/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

infix operator |: AdditionPrecedence

public extension Color {
    static func | (lightMode: Color, darkMode: Color) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .light ? UIColor(lightMode) : UIColor(darkMode)
        })
    }
}


struct AppStyle {
    struct Base {
        static var backgroundColor: Color {
            return .white | .black
        }
        
        static func navigationTitle(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .black | .white
            result.font = Font.custom("Lato-Black", size: 36)
            return result
        }
    }
    
    struct Login {
        static func appName(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .baseBlue | .white
            result.font = Font.custom("Lato-Bold", size: 26)
            return result
        }
        
        static func signInButton(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .baseGray3
            result.font = Font.custom("Lato-Bold", size: 16)
            return result
        }
        
        static func signInButtonAnonymous(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .baseGray3 | .baseGray1
            result.font = Font.custom("Lato-Bold", size: 16)
            return result
        }
        
        static var verticalSpacing: CGFloat {
            return 10.0
        }
        
        static var appLogoHeight: CGFloat {
            return 120.0
        }
        
        static var appLogoSpacing: CGFloat {
            return 40.0
        }
        
        static var buttonSize: CGSize {
            return CGSize(width: 240, height: 45)
        }
        
        static var backgroundColor: Color {
            return Color(uiColor: .baseGray1 | .black)
        }
    }
    
    struct About {
        static func text(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.5)
            result.font = Font.custom("Lato-Regular", size: 18)
            return result
        }
        
        static func url(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .black | .white
            result.font = Font.custom("Lato-Black", size: 18)
            return result
        }
        
        static func signature(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.5)
            result.font = Font.custom("Lato-Bold", size: 18)
            return result
        }
    }
    
    struct Audio {
        static func title(_ string: String, small: Bool = false) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .black | .white
            result.font = small ? Font.custom("Lato-Medium", size: 18) : Font.custom("Lato-Black", size: 21)
            return result
        }

        static func artist(_ string: String, small: Bool = false) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.7)
            result.font = small ? Font.custom("Lato-Regular", size: 14) : Font.custom("Lato-Regular", size: 17)
            return result
        }
        
        static func playlistTitle(_ string: String, isCurrent: Bool = false) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .black | .white
            result.font = isCurrent ? Font.custom("Lato-Black", size: 16) : Font.custom("Lato-Medium", size: 16)
            return result
        }

        static func playlistArtist(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.7)
            result.font = Font.custom("Lato-Regular", size: 14)
            return result
        }
        
        static func miniPlayerTitle(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.7)
            result.font = Font.custom("Lato-Bold", size: 16)
            return result
        }
        
        static func miniPlayerArtist(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.7)
            result.font = Font.custom("Lato-Regular", size: 15)
            return result
        }
        
        static func time(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.5)
            result.font = Font.custom("Lato-Bold", size: 14)
            return result
        }
        
        static func rate(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .black | .white
            result.font = Font.custom("Lato-Bold", size: 18)
            return result
        }
        
        static var miniPlayerHeight: CGFloat {
            return 60
        }
        
        static var miniPlayerContentPadding: CGFloat {
            return 10
        }
        
        static var miniPlayerCornerRadius: CGFloat {
            return 15
        }
    }
    
    struct Language {
        static func name(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = .black | .white
            result.font = Font.custom("Lato-Regular", size: 17)
            return result
        }
        
        static func translated(_ string: String) -> AttributedString {
            var result = AttributedString(string)
            result.foregroundColor = (.black | .white).opacity(0.5)
            result.font = Font.custom("Lato-Regular", size: 13)
            return result
        }
    }
    
    struct Feed {
        struct Spacing {
            static var horizontalPadding: CGFloat {
                return 20.0
            }
            
            static var betweenResources: CGFloat {
                return 20.0
            }
            
            static var insideBanner: CGFloat {
                return 15.0
            }
            
            static func betweenCoverAndTitle(_ direction: FeedGroupDirection) -> CGFloat {
                return direction == .horizontal ? 10.0 : 15.0
            }
            
            static var betweenTitleAndSubtitle: CGFloat {
                return 5.0
            }
        }
        
        struct GroupTitle {
            static func text(_ string: String, _ backgroundColorEnabled: Bool = false) -> AttributedString {
                var result = AttributedString(string.uppercased())
                result.foregroundColor = backgroundColorEnabled ? .white : (.baseBlue | .white.opacity(0.5))
                result.font = Font.custom("Lato-Bold", size: 13)
                return result
            }
        }
        
        struct SeeAllTitle {
            static func text(_ string: String, _ backgroundColorEnabled: Bool = false) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = backgroundColorEnabled ? .white : (.baseBlue | .white.opacity(0.5))
                result.font = Font.custom("Lato-Regular", size: 15)
                return result
            }
        }
        
        struct Title {
            static func text(_ string: String, _ larger: Bool = false, _ backgroundColorEnabled: Bool = false) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = backgroundColorEnabled ? .white : .black | .white
                result.font = Font.custom("Lato-Bold", size: larger ? 20 : 15)
                return result
            }
            
            static var lineLimit: Int {
                return 3
            }
        }
        
        struct Subtitle {
            static func text(_ string: String, _ larger: Bool = false, _ backgroundColorEnabled: Bool = false) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = (backgroundColorEnabled ? .white : .black | .white).opacity(0.5)
                result.font = Font.custom("Lato-Regular", size: 14)
                return result
            }
            
            static var lineLimit: Int {
                return 2
            }
        }
        
        struct Cover {
            // Calculates and returnes the size for the cover used in the Feed
            static func size(_ coverType: ResourceCoverType,
                             _ direction: FeedGroupDirection,
                             _ viewType: FeedGroupViewType,
                             _ initialWidth: CGFloat = UIScreen.main.bounds.width,
                             _ showTitle: Bool = true
            ) -> CGSize {
                let COVER_MAX_WIDTH = 210.0
                var width: CGFloat = initialWidth - 40 // TODO: spacing * 2
                var height = 200.0
                
                if direction == .vertical && showTitle {
                    switch coverType {
                    case .landscape:
                        if (viewType == .tile) {
                            width = width * 0.35
                        }
                        height = width / coverType.aspectRatio
                    case .portrait:
                        width = width * 0.30
                    case .square:
                        width = width * 0.30
                    case .splash:
                        height = width / coverType.aspectRatio
                    }
                }
                
                if direction == .horizontal {
                    switch coverType {
                    case .landscape:
                        if (Helper.isPad) {
                            width = width * 0.35
                        } else {
                            width = viewType == .banner ? width * 0.9 : width * 0.70
                        }
                        
                    case .portrait:
                        width = width * 0.40
                    case .square:
                        width = width * 0.40
                    case .splash:
                        height = width / coverType.aspectRatio
                    }
                }
                
                if (Helper.isPad
                    && ((direction == .horizontal && (viewType == .square || viewType == .folio))
                    || (direction == .vertical && (viewType == .square || viewType == .folio)))) {
                    width = min(width, COVER_MAX_WIDTH)
                }
                
                height = width / coverType.aspectRatio
                
                return CGSize(width: width, height: height)
            }
        }
    }
    
    struct Author {
        struct Splash {
            static var height: CGFloat {
                return UIScreen.main.bounds.height * (Helper.isPad && Helper.isLandscape ? 0.5 : 0.3)
            }
            
            static var gradientBlurHeight: CGFloat {
                return AppStyle.Resource.Splash.height * 0.5
            }
        }
    }
    
    struct Category {
        struct Splash {
            static var height: CGFloat {
                return UIScreen.main.bounds.height * (Helper.isPad && Helper.isLandscape ? 0.5 : 0.3)
            }
            
            static var gradientBlurHeight: CGFloat {
                return AppStyle.Resource.Splash.height * 0.5
            }
        }
    }
    
    struct Resource {
        struct Introduction {
            static var stylesheet: String {
                return "body { font-size: 1.6em; line-height: 1.4em; font-family: 'Lato', sans-serif; color: \((.black | .white).hex()) }"
            }
        }
        
        struct Spacing {
            static var betweenTitleSubtitleReadButonDescription: CGFloat {
                return 20.0
            }
            
            static var topPaddingForNonSplashImage: CGFloat {
                return 120.0
            }
            
            static var paddingForNonSplashHeader: CGFloat {
                return Helper.isPad ? 80.0 : 0
            }
            
            static var paddingForSplashHeader: CGFloat {
                return 20.0
            }
            
            static var paddingForFooter: CGFloat {
                return 20.0
            }
        }
        
        struct Splash {
            static var height: CGFloat {
                return UIScreen.main.bounds.height * (Helper.isPad && Helper.isLandscape ? 0.8 : 0.6)
            }
            
            static var gradientBlurHeight: CGFloat {
                return AppStyle.Resource.Splash.height * 0.5
            }
        }
        
        struct Cover {
            // Calculates and returnes the size for the cover used in the Resource for non splash
            static func size(_ coverType: ResourceCoverType) -> CGSize {
                let width: CGFloat = Helper.isPad ? 200 : UIScreen.main.bounds.width / 2.5
                let height = width / coverType.aspectRatio
                
                return CGSize(width: width, height: height)
            }
            
            static func nonSplashCover(_ coverType: ResourceCoverType) -> CGSize {
                let width: CGFloat = Helper.isPad ? 200 : UIScreen.main.bounds.width / (coverType == .portrait ? 2.5 : 1.5)
                let height = width / coverType.aspectRatio
                
                return CGSize(width: width, height: height)
            }
        }
        
        struct Header {
            static func frameAlignment(_ noSplash: Bool) -> Alignment {
                return noSplash && Helper.isPad ? .leading : .center
            }
            
            static func textAlignment(_ noSplash: Bool) -> TextAlignment {
                return noSplash && Helper.isPad ? .leading : .center
            }
            
            static func frameWidth(_ noSplash: Bool, _ width: CGFloat = UIScreen.main.bounds.width) -> CGFloat {
                let width = noSplash && Helper.isPad
                ? width - AppStyle.Resource.Cover.size(.portrait).width - AppStyle.Resource.Spacing.betweenTitleSubtitleReadButonDescription
                    : width
                return width - AppStyle.Resource.Spacing.paddingForSplashHeader * 2
            }
        }
        
        struct Title {
            static func text(_ string: String, _ style: Style?) -> AttributedString {
                var result = Styler.getStyledText(string, style, ResourceTitleStyleTemplate())
                if style == nil {
                    result.foregroundColor = .white
                    result.font = Font.custom("Lato-Black", size: 30)
                }
                return result
            }
            
            static var lineLimit: Int {
                return 3
            }
        }
        
        struct Subtitle {
            static func text(_ string: String, _ style: Style?) -> AttributedString {
                var result = Styler.getStyledText(string, style, ResourceSubtitleStyleTemplate())
                if style == nil {
                    result.foregroundColor = .white.opacity(0.7)
                    result.font = Font.custom("Lato-Bold", size: 13)
                }
                return result
            }
            
            static var lineLimit: Int {
                return 2
            }
        }
        
        struct Description {
            static func text(_ string: String, _ style: Style?) -> AttributedString {
                var result = Styler.getStyledText(string, style, ResourceDescriptionStyleTemplate())
                if style == nil {
                    result.foregroundColor = .white
                    result.font = Font.custom("Lato-Medium", size: 15)
                }
                return result
            }
            
            static func textMoreButton(_ string: String, _ color: Color = .white) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = color
                result.font = Font.custom("Lato-MediumItalic", size: 15)
                result.underlineStyle = .single
                return result
            }
            
            static var lineLimit: Int {
                return 3
            }
        }
        
        struct ReadButton {
            static func text(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = .white
                result.font = Font.custom("Lato-Bold", size: 15)
                return result
            }
            
            static func textSelectedDocument(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = .white.opacity(0.7)
                result.font = Font.custom("Lato-Regular", size: 13)
                return result
            }
            
            static var lineLimit: Int {
                return 1
            }
            
            static var width: CGFloat {
                return 200
            }
            
            static var shadowRadius: CGFloat {
                return 20.0
            }
            
            static var horizontalPadding: CGFloat {
                return 35.0
            }
            
            static var verticalPadding: CGFloat {
                return 8.0
            }
        }
        
        struct Credits {
            static var spacingBetweenCredits: CGFloat {
                return 20
            }
            
            static func creditName(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = (.black | .white).opacity(0.7)
                result.font = Font.custom("Lato-Bold", size: 15)
                return result
            }
            
            static func creditValue(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = (.black | .white).opacity(0.5)
                result.font = Font.custom("Lato-Regular", size: 15)
                return result
            }
        }
        
        struct Features {
            static var spacingBetweenSplashFeatures: CGFloat {
                return 10
            }
            
            static var spacingBetweenFeatures: CGFloat {
                return 20
            }
            
            static var spacingBetweenFeatureNameAndDescription: CGFloat {
                return 10
            }
            
            static var size: CGSize {
                return CGSize(width: 16, height: 12)
            }
            
            static func splashFeatureColor(_ featureColor: String? = nil) -> Color {
                return Color(hex: featureColor ?? "#ffffff").opacity(0.7)
            }
            
            static var color: Color {
                return (.black | .white).opacity(0.7)
            }
            
            static func featureName(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = (.black | .white).opacity(0.7)
                result.font = Font.custom("Lato-Bold", size: 15)
                return result
            }
            
            static func featureDescription(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = (.black | .white).opacity(0.5)
                result.font = Font.custom("Lato-Regular", size: 15)
                return result
            }
        }
        
        struct Section {
            struct Title {
                static func text(_ string: String) -> AttributedString {
                    var result = AttributedString(string.uppercased())
                    result.foregroundColor = (.black | .white).opacity(0.4)
                    result.font = Font.custom("Lato-Bold", size: 13)
                    return result
                }
                
                static var lineLimit: Int {
                    return 2
                }
                
                static var background: Color {
                    return Color(.black | .white).opacity(0.03)
                }
                
                static var padding: CGFloat {
                    return 20.0
                }
            }
            
            struct Dropdown {
                static func text(_ string: String) -> AttributedString {
                    var result = AttributedString(string)
                    result.foregroundColor = .black | .white
                    result.font = Font.custom("Lato-Bold", size: 18)
                    return result
                }
                
                static var chevronTint: Color {
                    return .black | .white
                }
                
                static var lineLimit: Int {
                    return 1
                }
                
                static var padding: CGFloat {
                    return 20.0
                }
            }
        }
        
        struct Document {
            struct Spacing {
                static var padding: CGFloat {
                    return 20.0
                }
                
                static var betweenTitleSubtitleAndDate: CGFloat {
                    return 5.0
                }
            }
            
            struct Title {
                static func text(_ string: String) -> AttributedString {
                    var result = AttributedString(string)
                    result.foregroundColor = .black | .white
                    result.font = Font.custom("Lato-Medium", size: 18)
                    return result
                }
                
                static var lineLimit: Int {
                    return 2
                }
            }
            
            struct Subtitle {
                static func text(_ string: String) -> AttributedString {
                    var result = AttributedString(string)
                    result.foregroundColor = (.black | .white).opacity(0.5)
                    result.font = Font.custom("Lato-Regular", size: 16)
                    return result
                }
                
                static var lineLimit: Int {
                    return 1
                }
            }
            
            struct Date {
                static func text(_ string: String) -> AttributedString {
                    var result = AttributedString(string)
                    result.foregroundColor = (.black | .white).opacity(0.5)
                    result.font = Font.custom("Lato-Regular", size: 16)
                    return result
                }
                
                static var lineLimit: Int {
                    return 1
                }
            }
            
            struct Sequence {
                static func text(_ string: String) -> AttributedString {
                    var result = AttributedString(string)
                    result.foregroundColor = (.black | .white).opacity(0.3)
                    result.font = Font.custom("Lato-Bold", size: 22)
                    return result
                }
                
                static var lineLimit: Int {
                    return 1
                }
            }
        }
        
        struct Copyright {
            static func text(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = (.black | .white).opacity(0.5)
                result.font = Font.custom("Lato-Regular", size: 15)
                return result
            }
        }
        
        struct Footer {
            static var color: Color {
                return (.black | .white).opacity(0.1)
            }
        }
    }
    
    struct Segment {
        struct Spacing {
            static var betweenTitleDateAndSubtitle: CGFloat {
                return 10.0
            }
            
            static func horizontalPaddingHeader(_ width: CGFloat = UIScreen.main.bounds.width, _ isHiddenSegment: Bool = false) -> CGFloat {
                return Helper.isPad && !isHiddenSegment ? (width * 0.10) + 20.0 : 20.0
            }
            
            static func verticalPaddingHeader() -> CGFloat {
                return 20.0
            }
            
            static var verticalPaddingContent: CGFloat {
                return 20.0
            }
            
            static func horizontalPaddingContent(_ width: CGFloat = UIScreen.main.bounds.width, _ isHiddenSegment: Bool = false) -> CGFloat {
                return Helper.isPad && !isHiddenSegment ? width * 0.10 : 0.0
            }
            
            static var betweenBlocks: CGFloat {
                return 20.0
            }
        }
        
        struct Cover {
            static func percentageOfScreen(_ hasCover: Bool = true, _ segmentType: SegmentType = .block) -> CGFloat {
                if segmentType == .video {
                    return 0.1
                }
                return hasCover ? 0.5 : 0.2
            }
            
            static func height (_ hasCover: Bool = true, _ segmentType: SegmentType = .block) -> CGFloat {
                return UIScreen.main.bounds.height * AppStyle.Segment.Cover.percentageOfScreen(hasCover)
            }
        }
        
        struct Title {
            static func text(_ string: String, _ hasCover: Bool, _ style: Style?) -> AttributedString {
                let template = SegmentTitleStyleTemplate(hasCover: hasCover)
                return Styler.getStyledText(string, style, template)
            }
            
            static var lineLimit: Int {
                return 3
            }
        }
        
        struct Subtitle {
            static func text(_ string: String, _ hasCover: Bool, _ style: Style?) -> AttributedString {
                let template = SegmentSubtitleStyleTemplate(hasCover: hasCover)
                return Styler.getStyledText(string.uppercased(), style, template)
            }
            
            static var lineLimit: Int {
                return 2
            }
        }
        
        struct Date {
            static func text(_ string: String, _ hasCover: Bool, _ style: Style?) -> AttributedString {
                let template = SegmentSubtitleStyleTemplate(hasCover: hasCover)
                return Styler.getStyledText(string.uppercased(), style, template)
            }
            
            static var lineLimit: Int {
                return 2
            }
        }
        
        struct Progress {
            static func saveButtonTitle(_ string: String) -> AttributedString {
                let theme = ThemeManager()
                var result = AttributedString(string)
                result.foregroundColor = theme.getTextColor()
                result.font = Font.custom("Lato-Bold", size: 18)
                return result
            }
            
            static func saveButtonSubtitle(_ string: String) -> AttributedString {
                let theme = ThemeManager()
                var result = AttributedString(string)
                result.foregroundColor = theme.getTextColor()
                result.font = Font.custom("Lato-Regular", size: 16)
                return result
            }
        }
    }
    
    struct Block {
        static func text(_ text: String, _ style: Style?, _ block: AnyBlock?, _ template: StyleTemplate = BlockStyleTemplate()) -> AttributedString {
            return Styler.getStyledText(text, style, template, block)
        }
        
        static func heading(_ text: String, _ style: Style?, _ block: AnyBlock?, _ depth: HeadingDepth) -> AttributedString {
            return AppStyle.Block.text(text, style, block, HeadingStyleTemplate(depth: depth))
        }
        
        static var highlightGreen: Color {
            return Color(hex: "#63D724")
        }
        
        static var highlightOrange: Color {
            return Color(hex: "#F59569")
        }
        
        static var highlightBlue: Color {
            return Color(hex: "#0079E7")
        }
        
        static var highlightYellow: Color {
            return Color(hex: "#C7DF00")
        }
        
        static var highlightPurple: Color {
            return Color(hex: "#A36AFC")
        }
        
        static var highlightBrown: Color {
            return Color(hex: "#A58064")
        }
        
        static var highlightRed: Color {
            return Color(hex: "#EC5252")
        }
        
        static var highlightForeground: Color {
            return Color(hex: "#222222")
        }
        
        static func genericBackgroundColorForInteractiveBlock(theme: ReaderStyle.Theme) -> Color {
            let light = Color.gray100
            let sepia = Color.sepia300
            let dark = Color.primary950
            
            switch theme {
            case .light:
                return light
            case .sepia:
                return sepia
            case .dark:
                return dark
            case .auto:
                return Helper.isDarkMode() ? dark : light
            }
        }
        
        static func genericForegroundColorForInteractiveBlock(theme: ReaderStyle.Theme) -> Color {
            let light = Color.black
            let sepia = Color(hex: "#5b4636")
            let dark = Color.white
            
            switch theme {
            case .light:
                return light
            case .sepia:
                return sepia
            case .dark:
                return dark
            case .auto:
                return Helper.isDarkMode() ? dark : light
            }
        }
        
        struct Reference {
            static var thumbnailSize: CGSize {
                return CGSize(width: 60, height: 90)
            }
            
            static func backgroundColor(theme: ReaderStyle.Theme) -> Color {
                return AppStyle.Block.genericBackgroundColorForInteractiveBlock(theme: theme)
            }
        }
        
        struct Collapse {
            static func backgroundColor(theme: ReaderStyle.Theme) -> Color {
                return AppStyle.Block.genericBackgroundColorForInteractiveBlock(theme: theme)
            }
        }
        
        struct Question {
            static func answerBackgroundColor(theme: ReaderStyle.Theme) -> Color {
                let light = Color(hex: "#faf8fa")
                let sepia = Color.sepia100
                let dark = Color(hex: "#111827")
                
                switch theme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
        }
        
        struct Completion {
            static func underlineColor() -> Color {
                let themeManager = ThemeManager()
                
                let light = Color.primary700
                let sepia = Color.sepia400
                let dark = Color.primary400
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return Helper.isDarkMode() ? dark : light
                }
            }
            
            static func backgroundColor() -> Color {
                let themeManager = ThemeManager()
                
                let light = Color.primary50
                let sepia = Color.sepia200
                let dark = Color.gray800
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return Helper.isDarkMode() ? dark : light
                }
            }
        }
        
        struct Checklist {
            static func checkmarkColor() -> Color {
                let themeManager = ThemeManager()
                
                let light = Color.gray500
                let sepia = Color.sepia400
                let dark = Color.white
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
            
            static func checkmarkBackgroundColor() -> Color {
                let themeManager = ThemeManager()
                
                let light = Color.gray50
                let sepia = Color.sepia300
                let dark = Color.gray900
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
            
            static func borderColor() -> Color {
                let themeManager = ThemeManager()
                
                let light = Color.gray300
                let sepia = Color.sepia400
                let dark = Color.primary800
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
        }
        
        struct Poll {
            static func borderColor() -> Color {
                let themeManager = ThemeManager()
                
                let light = Color.gray300
                let sepia = Color.sepia400
                let dark = Color.gray900
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
            
            static func resultBarColor(_ selected: Bool) -> Color {
                let themeManager = ThemeManager()
                
                let light = selected ? Color.gray600 : Color.gray300
                let sepia = selected ? Color.sepia400.opacity(0.5) : Color.sepia400
                let dark = selected ? Color.primary600 : Color.primary400
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
        }
        
        struct MultipleChoice {
            static func checkmarkColor(_ selected: Bool) -> Color {
                let themeManager = ThemeManager()
                
                let light = selected ? .white : Color.gray300
                let sepia = selected ? .white : Color.sepia400
                let dark = selected ? .white : Color.gray800
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
            
            static func checkmarkBackgroundColor(_ selected: Bool) -> Color {
                let themeManager = ThemeManager()
                
                let light = selected ? Color.gray300 : Color.gray50
                let sepia = selected ? Color.sepia400 : Color.sepia300
                let dark = selected ? Color.primary950 : Color.gray900
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
            
            static func borderColor() -> Color {
                let themeManager = ThemeManager()
                
                let light = Color.gray300
                let sepia = Color.sepia400
                let dark = Color.primary800
                
                switch themeManager.currentTheme {
                case .light:
                    return light
                case .sepia:
                    return sepia
                case .dark:
                    return dark
                case .auto:
                    return light | dark
                }
            }
        }
    }
    
    struct ThemeAux {
        static func sizeIndicator(active: Bool) -> Color {
            var color: Color = .black | .white
            if !active {
                color = color.opacity(0.2)
            }
            return color
        }
    }
    
    struct VideoAux {
        struct Size {
            static func thumbnail(viewMode: VideoCollectionItemViewMode = .horizontal, constrainedWidth: CGFloat = 0.0) -> CGSize {
                let defaultSize = CGSize(width: 276, height: 149)
                
                let ratio: CGFloat = viewMode == .vertical ? 2.7 : 1.2
                
                var maxWidth: CGFloat = viewMode == .vertical && constrainedWidth > 0 ? constrainedWidth : UIScreen.main.bounds.width
                
                if Helper.isPad && viewMode == .horizontal {
                    maxWidth = defaultSize.width
                }
                
                let width = maxWidth / ratio
                
                let height = width / (defaultSize.width / defaultSize.height)
                
                return CGSize(width: width, height: height)
            }
        }
        
        struct Text {
            static func collectionArtist(_ string: String) -> AttributedString {
                var result = AttributedString(string.uppercased())
                result.foregroundColor = .baseBlue | .white.opacity(0.5)
                result.font = Font.custom("Lato-Bold", size: 13)
                return result
            }
            
            static func title(_ string: String, _ featured: Bool = false) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = .black | .white
                result.font = Font.custom("Lato-Bold", size: 16) // 19 for featured
                return result
            }
            
            static func subtitle(_ string: String) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = .black.opacity(0.7) | .white.opacity(0.7)
                result.font = Font.custom("Lato-Regular", size: 14) // 19 for featured
                return result
            }
        }
    }
    
    struct VideoSegment {
        struct Text {
            static func title(_ string: String, _ featured: Bool = false) -> AttributedString {
                let themeManager = ThemeManager()
                
                var result = AttributedString(string)
                result.foregroundColor = themeManager.getTextColor()
                result.font = Font.custom("Lato-Bold", size: 16)
                return result
            }
            
            static func subtitle(_ string: String) -> AttributedString {
                let themeManager = ThemeManager()
                
                var result = AttributedString(string)
                result.foregroundColor = themeManager.getTextColor().opacity(0.7)
                result.font = Font.custom("Lato-Regular", size: 14)
                return result
            }
        }
    }
}
