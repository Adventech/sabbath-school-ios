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
                return .baseGray1 | .baseGray4
            }
            
            static var shimmering: UIColor {
                return AppStyle.Base.Color.control
            }
            
            static var tint: UIColor {
                guard let color = UserDefaults.standard.string(forKey: Constants.DefaultKey.tintColor) else {
                    return .baseBlue
                }
                return UIColor(hex: color)
            }
        }
        
        struct Text {
            static func navBarButton(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
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
        }
        
        struct Text {
            static func title(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: AppStyle.Base.Color.text,
                    .font: R.font.latoBold(size: 24)!
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            
            static func featuredTitle(string: String) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: R.font.latoBold(size: 30)!
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
    }
    
    struct Lesson {
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

            static func introduction(string: String, color: UIColor = .baseGray2) -> NSAttributedString {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
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
        }
    }
    
    struct Read {
        struct Color {
            static var background: UIColor {
                return .baseWhite1 | .baseGray5
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

            static var whiteFont: UIColor {
                return UIColor.baseGray4
            }

            static var dark: UIColor {
                return UIColor(hex: "#000000")
            }

            static var darkFont: UIColor {
                return UIColor(hex: "#acacac")
            }

            static var sepia: UIColor {
                return UIColor(hex: "#FBF0D9")
            }

            static var sepiaFont: UIColor {
                return UIColor(hex: "#5b4636")
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
