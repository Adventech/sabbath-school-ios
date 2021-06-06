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
}
