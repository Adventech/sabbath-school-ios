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
            static func thumbnail(viewMode: VideoCollectionItemViewMode = .horizontal) -> CGSize {
                let defaultSize = CGSize(width: 276, height: 149)
                
                let ratio: CGFloat = viewMode == .vertial ? 2.7 : 1.2
                
                let width = Helper.isPad ? defaultSize.width : UIScreen.main.bounds.width / ratio
                let height = Helper.isPad ? defaultSize.height : width / (defaultSize.width / defaultSize.height)
                
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
    
    static func convertTypingAttribute(_ attributes: [NSAttributedString.Key: Any]) -> [String: Any] {
        var typingAttribute: [String: Any] = [:]
        
        for key in attributes.keys {
            guard let attr = attributes[key] else { continue }
            typingAttribute[key.rawValue] = attr
        }
        
        return typingAttribute
    }
}
