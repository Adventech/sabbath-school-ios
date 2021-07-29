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
