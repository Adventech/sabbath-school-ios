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
import Hue
import SwiftUI

infix operator |: AdditionPrecedence

enum Theme: String {
  case Dark
  case Light
}

public extension UIColor {
    // Base UI color scheme
    class var baseBlue: UIColor {
        return UIColor(hex: "#2E5797")
    }
    
    // TODO: rename to baseGray1
    class var baseWhite1: UIColor {
        return UIColor(hex: "#E2E2E5")
    }

    class var baseGray1: UIColor {
        return UIColor(hex: "#EFEFEF")
    }

    class var baseGray2: UIColor {
        return UIColor(hex: "#8F8E94")
    }

    class var baseGray3: UIColor {
        return UIColor(hex: "#606060")
    }

    class var baseGray4: UIColor {
        return UIColor(hex: "#383838")
    }
    
    // TODO: consider deprecating
    class var baseGray5: UIColor {
        return UIColor(hex: "#1A1A1A")
    }

    class var baseRed: UIColor {
        return UIColor(hex: "#F1706B")
    }
    
    static func | (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
    
    class func transitionColor(fromColor:UIColor, toColor:UIColor, progress:CGFloat) -> UIColor {
        var percentage = progress < 0 ?  0 : progress
        percentage = percentage > 1 ?  1 : percentage

        var fRed:CGFloat = 0
        var fBlue:CGFloat = 0
        var fGreen:CGFloat = 0
        var fAlpha:CGFloat = 0

        var tRed:CGFloat = 0
        var tBlue:CGFloat = 0
        var tGreen:CGFloat = 0
        var tAlpha:CGFloat = 0

        fromColor.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        toColor.getRed(&tRed, green: &tGreen, blue: &tBlue, alpha: &tAlpha)

        let red:CGFloat = (percentage * (tRed - fRed)) + fRed;
        let green:CGFloat = (percentage * (tGreen - fGreen)) + fGreen;
        let blue:CGFloat = (percentage * (tBlue - fBlue)) + fBlue;
        let alpha:CGFloat = (percentage * (tAlpha - fAlpha)) + fAlpha;

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
    
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
}

public extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red, green, blue, alpha: Double
        switch hexSanitized.count {
        case 6:
            red = Double((rgb & 0xFF0000) >> 16) / 255.0
            green = Double((rgb & 0x00FF00) >> 8) / 255.0
            blue = Double(rgb & 0x0000FF) / 255.0
            alpha = 1.0
        case 8:
            red = Double((rgb & 0xFF000000) >> 24) / 255.0
            green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = Double(rgb & 0x000000FF) / 255.0
        default:
            red = 0.0
            green = 0.0
            blue = 0.0
            alpha = 1.0
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    static let baseBlue: Color = Color(hex: "#003877")
//    static let baseBlue: Color = Color(hex: "#2E5797")
    
    static let primary: Color = Color(hex: "#005EC7")
    static let primary50: Color = Color(hex: "#F2F7FC")
    static let primary100: Color = Color(hex: "#E5EFF9")
    static let primary200: Color = Color(hex: "#CCDFF4")
    static let primary300: Color = Color(hex: "#99BFE9")
    static let primary400: Color = Color(hex: "#669EDD")
    static let primary500: Color = Color(hex: "#337DD2")
    static let primary600: Color = Color(hex: "#005EC7")
    static let primary700: Color = Color(hex: "#004A9F")
    static let primary800: Color = Color(hex: "#003877")
    static let primary900: Color = Color(hex: "#002550")
    static let primary950: Color = Color(hex: "#001328")
    static let primary980: Color = Color(hex: "#222222")
    
    static let gray20: Color = Color(hex: "#F9FAFB")
    static let gray50: Color = Color(hex: "#ECEFF2")
    static let gray100: Color = Color(hex: "#D9DFE6")
    static let gray200: Color = Color(hex: "#B3BFCC")
    static let gray300: Color = Color(hex: "#94A6B8")
    static let gray400: Color = Color(hex: "#758CA3")
    static let gray500: Color = Color(hex: "#668099")
    static let gray600: Color = Color(hex: "#5C738A")
    static let gray700: Color = Color(hex: "#47596B")
    static let gray800: Color = Color(hex: "#33404C")
    static let gray900: Color = Color(hex: "#1F262E")
    static let gray950: Color = Color(hex: "#141A1F")
    static let gray980: Color = Color(hex: "#adadad")
    
    static let sepia100: Color = Color(hex: "#FDF4E6")
    static let sepia200: Color = Color(hex: "#E8DAC4")
    static let sepia300: Color = Color(hex: "#E0D0B8")
    static let sepia400: Color = Color(hex: "#3E3634")
}
