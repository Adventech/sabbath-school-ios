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

import UIKit
import Down

struct SSPMColorCollection: ColorCollection {
    public var heading1: DownColor
    public var heading2: DownColor
    public var heading3: DownColor
    public var heading4: DownColor
    public var heading5: DownColor
    public var heading6: DownColor
    public var body: DownColor
    public var code: DownColor
    public var link: DownColor
    public var quote: DownColor
    public var quoteStripe: DownColor
    public var thematicBreak: DownColor
    public var listItemPrefix: DownColor
    public var codeBlockBackground: DownColor

    public init(
        heading1: DownColor = .black,
        heading2: DownColor = .black,
        heading3: DownColor = .black,
        heading4: DownColor = .black,
        heading5: DownColor = .black,
        heading6: DownColor = .black,
        body: DownColor = AppStyle.Quarterly.Color.introduction,
        code: DownColor = AppStyle.Quarterly.Color.introduction,
        link: DownColor = AppStyle.Quarterly.Color.introduction,
        quote: DownColor = .darkGray,
        quoteStripe: DownColor = .darkGray,
        thematicBreak: DownColor = .init(white: 0.9, alpha: 1),
        listItemPrefix: DownColor = .lightGray,
        codeBlockBackground: DownColor = .init(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    ) {
        self.heading1 = heading1
        self.heading2 = heading2
        self.heading3 = heading3
        self.heading4 = heading4
        self.heading5 = heading5
        self.heading6 = heading6
        self.body = body
        self.code = code
        self.link = link
        self.quote = quote
        self.quoteStripe = quoteStripe
        self.thematicBreak = thematicBreak
        self.listItemPrefix = listItemPrefix
        self.codeBlockBackground = codeBlockBackground
    }

}

struct SSPMParagraphStyleCollection: ParagraphStyleCollection {
    public var heading1: NSParagraphStyle
    public var heading2: NSParagraphStyle
    public var heading3: NSParagraphStyle
    public var heading4: NSParagraphStyle
    public var heading5: NSParagraphStyle
    public var heading6: NSParagraphStyle
    public var body: NSParagraphStyle
    public var code: NSParagraphStyle

    public init() {
        let headingStyle = NSMutableParagraphStyle()
        headingStyle.paragraphSpacing = 8

        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.paragraphSpacingBefore = 0
        bodyStyle.paragraphSpacing = 0
        bodyStyle.lineSpacing = 3

        let codeStyle = NSMutableParagraphStyle()
        codeStyle.paragraphSpacingBefore = 8
        codeStyle.paragraphSpacing = 8

        heading1 = headingStyle
        heading2 = headingStyle
        heading3 = headingStyle
        heading4 = headingStyle
        heading5 = headingStyle
        heading6 = headingStyle
        body = bodyStyle
        code = codeStyle
    }
}

class SSPMFontCollection: FontCollection {
    public var heading1: DownFont
    public var heading2: DownFont
    public var heading3: DownFont
    public var heading4: DownFont
    public var heading5: DownFont
    public var heading6: DownFont
    public var body: DownFont
    public var code: DownFont
    public var listItemPrefix: DownFont

    public init(
        heading1: DownFont = R.font.latoRegular(size: 28)!,
        heading2: DownFont = R.font.latoRegular(size: 24)!,
        heading3: DownFont = R.font.latoRegular(size: 20)!,
        heading4: DownFont = R.font.latoRegular(size: 20)!,
        heading5: DownFont = R.font.latoRegular(size: 20)!,
        heading6: DownFont = R.font.latoRegular(size: 20)!,
        body: DownFont = R.font.latoMedium(size: 19)!,
        code: DownFont = DownFont(name: "menlo", size: 17) ?? .systemFont(ofSize: 17),
        listItemPrefix: DownFont = DownFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
    ) {
        self.heading1 = heading1
        self.heading2 = heading2
        self.heading3 = heading3
        self.heading4 = heading4
        self.heading5 = heading5
        self.heading6 = heading6
        self.body = body
        self.code = code
        self.listItemPrefix = listItemPrefix
    }
}

class SSPMStyler: DownStyler {
    override func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        guard let url = url else { return }
        
        // TODO: In future style URLs depending on their type potentially
        str.addAttributes(
            [
                .link: url,
                .font: R.font.latoBold(size: 18)!,
                .foregroundColor: UIColor.baseBlue,
                .underlineColor: UIColor.clear
            ],
            range: NSRange(location: 0, length: str.length)
        )
    }
}

struct AppStyle {
    struct Base {
        struct Button {
            static func pillButtonUIEdgeInsets() -> UIEdgeInsets {
                return UIEdgeInsets(top: 8, left: 40, bottom: 8, right: 40)
            }
        }
        
        struct Color {
            static var navigationTitle: UIColor {
                return .black | .white
            }
            
            static var navigationTint: UIColor {
                return AppStyle.Base.Color.navigationTitle
            }
            
            static var background: UIColor {
                return .white | .black
            }
            
            static var text: UIColor {
                return .baseGray3 | .baseGray1
            }
            
            static var tableCellBackground: UIColor {
                return .white | .black
            }
            
            static var control: UIColor {
                return .baseGray1 | .baseGray5
            }
            
            static var controlActive: UIColor {
                return AppStyle.Base.Color.tint | .baseGray1
            }
            
            static var controlActive2: UIColor {
                return AppStyle.Base.Color.tint | .white
            }
            
            static var tableCellBackgroundHighlighted: UIColor {
                return AppStyle.Base.Color.control
            }
            
            static var tableSeparator: UIColor {
                return .baseGray1 | .baseGray5
            }
            
            static var shimmering: UIColor {
                return AppStyle.Base.Color.control
            }
            
            static var tint: UIColor {
                return AppStyle.Base.Color.navigationTint
            }
        }
        
        struct Text {
            static func navBarButton(string: String, color: UIColor = AppStyle.Base.Color.navigationTitle) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
                    .font: R.font.latoRegular(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Login {
        struct Color {
            static var facebookBlue: UIColor {
                return UIColor(hex: "#3B529A")
            }
            
            static var background: UIColor {
                return .baseGray1 | .black
            }
            
            static var foreground: UIColor {
                return .baseBlue | .white
            }
        }
        
        struct Text {
            static func signInButton(string: String, color: UIColor = .baseGray3) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
                    .font: R.font.latoBold(size: 16)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func signInButtonAnonymous(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoBold(size: 16)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }

            static func appName(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Login.Color.foreground,
                    .font: R.font.latoBold(size: 26)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Language {
        struct Color {
            static var background: UIColor {
                return AppStyle.Base.Color.tableCellBackground
            }
            
            static var backgroundHighlighted: UIColor {
                return AppStyle.Base.Color.tableCellBackgroundHighlighted
            }
        }
        
        struct Text {
            static func name(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoRegular(size: 17)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func translated(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoRegular(size: 13)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func search() -> [String: Any] {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoRegular(size: 17)!
                ]
                return AppStyle.convertTypingAttribute(attributes)
            }
            
            static func searchPlaceholder(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoRegular(size: 17)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Quarterly {
        struct Size {
            static func coverImage() -> CGSize {
                let defaultSize = CGSize(width: 187, height: 276)
                if Helper.isPad { return defaultSize }
                
                let width = UIScreen.main.bounds.width / 2.7
                
                return CGSize(width: width, height: width / (defaultSize.width / defaultSize.height))
            }
            
            static func xPadding() -> CGFloat {
                return Helper.isPad ? 20 : 10
            }
            
            static func xInset() -> CGFloat {
                return 10
            }
        }
        
        struct Button {
            static func openButtonUIEdgeInsets() -> UIEdgeInsets {
                return AppStyle.Base.Button.pillButtonUIEdgeInsets()
            }
        }
        
        struct Color {
            static var background: UIColor {
                return AppStyle.Base.Color.tableCellBackground
            }
            
            static var backgroundHighlighted: UIColor {
                return AppStyle.Base.Color.tableCellBackgroundHighlighted
            }
            
            static var gradientStart: UIColor {
                return .white | .black
            }
            
            static var gradientEnd: UIColor {
                return UIColor.baseWhite1.lighter() | .black
            }
            
            static var seeAll: UIColor {
                return UIColor.baseBlue | .white
            }
            
            static var seeAllIcon: UIColor {
                return UIColor.baseGray2.lighter(componentDelta: 0.2) | UIColor.white
            }
            
            static var introduction: UIColor {
                return UIColor(hex: "#222222") | UIColor(hex: "#ADADAD")
            }
        }
        
        struct Text {
            static func introduction(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoMedium(size: 18)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func mainTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.navigationTitle,
                    .font: R.font.latoBlack(size: 36)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func groupName(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .baseBlue | UIColor.baseGray2,
                    .font: R.font.latoBold(size: 13)!
                ]
                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }
            
            static func seeMore(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Quarterly.Color.seeAll,
                    .font: R.font.latoRegular(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func titleV2(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.navigationTitle,
                    .font: R.font.latoBold(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func title(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoBold(size: 24)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func featuredTitle(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: R.font.latoBold(size: 30)!,
                    .paragraphStyle: style
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func humanDate(string: String, color: UIColor = UIColor.white.withAlphaComponent(0.7)) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
                    .font: R.font.latoBold(size: 13)!
                ]
                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }
            
            static func openButton(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: R.font.latoBold(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func gcPopupText(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                style.lineSpacing = 6

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 18)!,
                    .foregroundColor: AppStyle.Base.Color.text,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
        }
        
        struct Style {
            static var introductionStylesheet: String {
                return "body { font-size: 1.6em; line-height: 1.4em; font-family: 'Lato', sans-serif; color: \(AppStyle.Quarterly.Color.introduction.hex()) }"
            }
        }
    }
    
    struct Lesson {
        struct Size {
            static func coverImage() -> CGSize {
                let defaultSize = CGSize(width: 187, height: 276)
                if Helper.isPad { return defaultSize }
                
                let width = UIScreen.main.bounds.width / 2.7
                
                return CGSize(width: width, height: width / (defaultSize.width / defaultSize.height))
            }
            
            static func splashCoverImageHeight() -> CGFloat {
                return UIScreen.main.bounds.height / 1.7
            }
            
            static func featureImage() -> CGSize {
                return CGSize(width: 16, height: 12)
            }
        }
        
        struct Button {
            static func readButtonUIEdgeInsets() -> UIEdgeInsets {
                return AppStyle.Base.Button.pillButtonUIEdgeInsets()
            }
        }
        
        struct Color {
            static var background: UIColor {
                return AppStyle.Base.Color.tableCellBackground
            }
            
            static var backgroundHighlighted: UIColor {
                return AppStyle.Base.Color.tableCellBackgroundHighlighted
            }
            
            static var copyright: UIColor {
                return .baseGray2 | .baseGray3
            }
            
            static var publishingHouseInfo: UIColor {
                return .baseGray2 | .baseGray3
            }
            
            static var backgroundFooter: UIColor {
                return .baseGray1 | UIColor.black.lighter()
            }
        }
        
        struct Text {
            static func readButton(string: String) -> NSAttributedString {
                return AppStyle.Quarterly.Text.openButton(string: string)
            }
            
            static func title(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoMedium(size: 18)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }

            static func dateRange(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoRegular(size: 16)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }

            static func introduction(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: R.font.latoMedium(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func index(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2.withAlphaComponent(0.5),
                    .font: R.font.latoBold(size: 22)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func creditsName(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoBold(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func creditsValue(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoRegular(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func copyright(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Lesson.Color.copyright,
                    .font: R.font.latoRegular(size: 15)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func publishingHouseInfo(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Lesson.Color.copyright,
                    .font: R.font.latoRegular(size: 13)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Read {
        struct Color {
            static var background: UIColor {
                return .baseWhite1 | .baseGray5
            }
            
            static var tint: UIColor {
                return AppStyle.Base.Color.tint | .white
            }
        }
        
        struct Text {
            static func title(string: String, color: UIColor = .white) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
                    .font: R.font.latoBold(size: 36)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func date(string: String) -> NSAttributedString {
                return AppStyle.Quarterly.Text.humanDate(string: string, color: UIColor.white.withAlphaComponent(0.7))
            }
        }
    }
    
    struct ReadOptions {
        struct Text {
            static func button() -> [NSAttributedString.Key: Any] {
                return [
                    .font: R.font.latoRegular(size: 16)!,
                    .foregroundColor: UIColor.baseGray2
                ]
            }
            
            static func buttonSelected() -> [NSAttributedString.Key: Any] {
                return [
                    .font: R.font.latoRegular(size: 16)!,
                    .foregroundColor: AppStyle.Base.Color.controlActive2
                ]
            }
            
            static func fontSizeSmallest(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 16)!,
                    .foregroundColor: UIColor.baseGray2,
                    .paragraphStyle: style
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func fontSizeLargest(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoBold(size: 24)!,
                    .foregroundColor: UIColor.baseGray2,
                    .paragraphStyle: style
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Reader {
        struct Color {
            static var white: UIColor {
                return UIColor(hex: "#FDFDFD")
            }

            static var dark: UIColor {
                return UIColor(hex: "#000000")
            }

            static var sepia: UIColor {
                return UIColor(hex: "#FBF0D9")
            }

            static var auto: UIColor {
                Preferences.darkModeEnable() ? dark:white
            }
        }
    }
    
    struct Bible {
        struct Text {
            static func title(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoRegular(size: 17)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Audio {
        struct Color {
            static var topIndicator: UIColor {
                return .baseGray1 | .baseGray2
            }
            
            static var progressThumb: UIColor {
                return UIColor.baseWhite1.darker() | .baseGray1
            }
            
            static var progressTint: UIColor {
                return .baseGray1 | .baseGray3
            }
            
            static var auxControls: UIColor {
                return .baseBlue | UIColor.baseGray2
            }
            
            static var miniPlayerBackground: UIColor {
                return .baseGray1 | UIColor.black.lighter()
            }
        }
        
        struct Size {
            static func coverImage(coverRatio: String = "portrait", isMini: Bool = false) -> CGSize {
                let isSquare: Bool = coverRatio == "square"
                
                let defaultSize = isSquare ? CGSize(width: 276, height: 276) : CGSize(width: 187, height: 276)
                
                var width = Helper.isPad ? defaultSize.width : UIScreen.main.bounds.width / (isSquare ? 1.5 : 2.7)
                var height = Helper.isPad ? defaultSize.height : width / (defaultSize.width / defaultSize.height)
                
                if isMini {
                    width /= 2
                    height /= 2
                }
                
                return CGSize(width: width, height: height)
            }
            
            static func miniPlayerWidth(constrainedWidth: CGFloat) -> CGFloat {
                return constrainedWidth > 650 ? 650 : constrainedWidth
            }
        }
        
        struct Text {
            static func title(string: String, alignment: NSTextAlignment = .center, small: Bool = false) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = alignment
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: small ? R.font.latoMedium(size: 18)! : R.font.latoBlack(size: 21)!,
                    .paragraphStyle: style
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }

            static func artist(string: String, alignment: NSTextAlignment = .center, small: Bool = false) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = alignment
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: small ? R.font.latoRegular(size: 14)! : R.font.latoRegular(size: 17)!,
                    .paragraphStyle: style
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func playlistTitle(string: String, isCurrent: Bool = false) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: isCurrent ? R.font.latoBlack(size: 16)! : R.font.latoMedium(size: 16)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }

            static func playlistArtist(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoRegular(size: 14)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func miniPlayerTitle(string: String, isCurrent: Bool = false) -> NSAttributedString {
                return AppStyle.Audio.Text.playlistTitle(string: string, isCurrent: isCurrent)
            }

            static func miniPlayerArtist(string: String) -> NSAttributedString {
                return AppStyle.Audio.Text.playlistArtist(string: string)
            }
            
            static func time(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseWhite1.darker() | .baseGray2,
                    .font: R.font.latoBold(size: 14)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func rate(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Audio.Color.auxControls,
                    .font: R.font.latoBold(size: 18)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Video {
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
            static func collectionTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .baseBlue | UIColor.baseGray2,
                    .font: R.font.latoBold(size: 13)!
                ]
                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }
            
            static func title(string: String, featured: Bool = false) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.navigationTitle,
                    .font: R.font.latoBold(size: featured ? 19 : 16)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func subtitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoRegular(size: 14)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func duration(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: R.font.latoMedium(size: 12)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct About {
        struct Text {
            static func slogan(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 15)!,
                    .foregroundColor: AppStyle.Base.Color.text,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }

            static func url(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 18)!,
                    .foregroundColor: AppStyle.Base.Color.controlActive2,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }

            static func text(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                style.lineSpacing = 6

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 18)!,
                    .foregroundColor: AppStyle.Base.Color.text,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }

            static func signature(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .left

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoBold(size: 18)!,
                    .foregroundColor: AppStyle.Base.Color.text,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Settings {
        struct Text {
            static func header(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .left

                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoMedium(size: 12)!,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }

            static func footer(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .left

                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoMedium(size: 12)!,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }

            static func copyright(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 11)!,
                    .foregroundColor: UIColor.baseGray2,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }

            static func title(string: String, danger: Bool = false) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 16)!,
                    .foregroundColor: danger ? UIColor.baseRed : AppStyle.Base.Color.text,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func detail(string: String) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 15)!,
                    .foregroundColor: UIColor.baseGray2,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Devo {
        struct Color {
            static func resourceDetailSectionBackground() -> UIColor {
                return .baseGray1 | .baseGray5
            }
        }
        struct Text {
            static func resourceDetailSection(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoBold(size: 12)!
                ]
                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }
            
            static func resourceDetailDocumentTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .baseGray4 | .baseGray1,
                    .font: R.font.latoRegular(size: 18)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceDetailDocumentSubtitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2.lighter() | .baseGray3,
                    .font: R.font.latoBold(size: 12)!
                ]
                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }
            
            static func openButtonTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .black | .white,
                    .font: R.font.latoBold(size: 18)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func openButtonSubtitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.baseGray2,
                    .font: R.font.latoRegular(size: 14)!
                ]
                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }
            
            static func resourceGroupName(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoBold(size: 13)!,
                    .foregroundColor: .baseGray5 | .baseGray2
                ]

                return NSAttributedString(string: string.uppercased(), attributes: attributes)
            }
            
            static func resourceListTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoBold(size: 18)!,
                    .foregroundColor: .black | .white
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceListTitle(string: String) -> AttributedString {
                var container = AttributeContainer()
                container.foregroundColor = .black | .white
                container.font = R.font.latoBold(size: 18)!

                let attributedString = AttributedString(string, attributes: container)
                return attributedString
            }
            
            static func resourceListSubtitle(string: String) -> AttributedString {
                var container = AttributeContainer()
                container.foregroundColor = .baseGray2 | .baseGray3
                container.font = R.font.latoRegular(size: 13)!

                let attributedString = AttributedString(string, attributes: container)
                return attributedString
            }
            
            static func resourceListSubtitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 13)!,
                    .foregroundColor: .baseGray2 | .baseGray3
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceTileSubtitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 15)!,
                    .foregroundColor: UIColor.baseGray3
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceTileTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoBold(size: 19)!,
                    .foregroundColor: .black | .white
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceTileSmallSubtitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 15)!,
                    .foregroundColor: UIColor.white
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceTileSmallTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoBold(size: 19)!,
                    .foregroundColor: UIColor.white
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceDetailTitleForColor(string: String, textColor: UIColor = UIColor.white) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoBlack(size: 28)!,
                    .foregroundColor: textColor,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func resourceDetailSubtitleForColor(string: String, textColor: UIColor = UIColor.white) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: R.font.latoRegular(size: 14)!,
                    .foregroundColor: textColor,
                    .paragraphStyle: style
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
    
    struct Markdown {
        struct Color {
            struct Reference {
                static var actionIcon: UIColor {
                    return .baseGray2
                }
            }
        }
        
        struct Text {
            struct Head {
                static func title(string: String) -> NSAttributedString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: .black | .white,
                        .font: R.font.latoBlack(size: 28)!
                    ]
                    return NSAttributedString(string: string, attributes: attributes)
                }
                static func subtitle(string: String) -> NSAttributedString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.baseGray2,
                        .font: R.font.latoRegular(size: 13)!
                    ]
                    return NSAttributedString(string: string, attributes: attributes)
                }
            }

            struct Reference {
                static func title(string: String) -> NSAttributedString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: .black | .white,
                        .font: R.font.latoMedium(size: 16)!
                    ]
                    return NSAttributedString(string: string, attributes: attributes)
                }

                static func subtitle(string: String) -> NSAttributedString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.baseGray2,
                        .font: R.font.latoRegular(size: 14)!
                    ]
                    return NSAttributedString(string: string, attributes: attributes)
                }
            }
            
            struct Blockquote {
                static func memoryText(string: String) -> NSAttributedString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: .black | .white,
                        .font: R.font.latoBold(size: 17)!
                    ]
                    return NSAttributedString(string: string, attributes: attributes)
                }
                static func citation(string: String) -> NSAttributedString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: .black | .white,
                        .font: R.font.latoItalic(size: 14)!
                    ]
                    return NSAttributedString(string: string, attributes: attributes)
                }
            }
            
            struct Image {
                static func caption(string: String) -> NSAttributedString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.baseGray2,
                        .font: R.font.latoItalic(size: 14)!
                    ]
                    return NSAttributedString(string: string, attributes: attributes)
                }
            }
            
            static func collapseHeader(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .black | .white,
                    .font: R.font.latoMedium(size: 16)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func answer() -> [String: Any] {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .black | .white,
                    .font: R.font.latoRegular(size: 17)!
                ]
                return AppStyle.convertTypingAttribute(attributes)
            }
            
            static func question(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .black | .white,
                    .font: R.font.latoBlack(size: 20)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func listBullet(string: String, ordered: Bool = false) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .black | .white,
                    .font: R.font.latoMedium(size: ordered ? 18 : 13)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func heading(string: String, depth: Int) -> NSAttributedString {
                let style = NSMutableParagraphStyle()
                
                // TODO: get options for local overrides
                style.alignment = .left
                
                // TODO: implement app / document level overrides
                
                var fontSize: Int
                
                switch depth {
                case 1:
                    fontSize = 26
                case 2:
                    fontSize = 24
                case 3:
                    fontSize = 23
                case 4:
                    fontSize = 22
                case 5:
                    fontSize = 21
                case 6:
                    fontSize = 20
                default:
                    fontSize = 20
                }
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: .black | .white,
                    .paragraphStyle: style,
                    .font: R.font.latoBlack(size: CGFloat(fontSize))!,
                ]

                return NSAttributedString(string: string, attributes: attributes)
            }
        }
        
        struct Size {
            static func headingSpacing() -> (top: CGFloat, bottom: CGFloat)  {
                return (10.0, 10.0)
            }
        }
    }
    
    static func convertTypingAttribute(_ attributes: [NSAttributedString.Key: Any]) -> [String: Any] {
        var typingAttribute: [String: Any] = [:]
        
        for key in attributes.keys {
            guard let attr = attributes[key] else { continue }
            typingAttribute[key.rawValue] = attr
        }
        
        return typingAttribute
    }
}
