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

extension UIColor {
    class var baseGreen: UIColor {
        return UIColor(hex: "#16A365")
    }
    
    class var baseSeparator: UIColor {
        return UIColor(hex: "#D7D7D7")
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
    
    class var baseGray5: UIColor {
        return UIColor(hex: "#3B3F3F")
    }
    
    class var baseGray6: UIColor {
        return UIColor(hex: "#FAFAFA")
    }
    
    class var baseGray7: UIColor {
        return UIColor(hex: "#E2E2E5")
    }
    
    class var baseRed: UIColor {
        return UIColor(hex: "#F1706B")
    }
    
    class var baseGrayToolbar: UIColor {
        return UIColor.black
    }
    
    class var baseSuperLightBlue: UIColor {
        return UIColor(hex: "#F3FAF9")
    }
    
    class var facebook: UIColor {
        return UIColor(hex: "#3B529A")
    }
    
    class var tintColor: UIColor {
        guard let appDelegate = UIApplication.shared.delegate,
            let window = appDelegate.window,
            let tintColor = window?.tintColor else { return UIColor.baseGreen }
        return tintColor
    }
    
    class var readerWhite: UIColor {
        return UIColor.white
    }
    
    class var readerWhiteFont: UIColor {
        return UIColor.baseGray4
    }
    
    class var readerDark: UIColor {
        return UIColor(hex: "#292929")
    }
    
    class var readerDarkFont: UIColor {
        return UIColor(hex: "#efefef")
    }
    
    class var readerSepia: UIColor {
        return UIColor(hex: "#FBF0D9")
    }
    
    class var readerSepiaFont: UIColor {
        return UIColor(hex: "#5b4636")
    }
    
    class var readerSeparator: UIColor {
        return UIColor(white: 0.5, alpha: 0.2)
    }
    
    class var readerNormal: UIColor {
        return UIColor(white: 0.5, alpha: 0.7)
    }
}
