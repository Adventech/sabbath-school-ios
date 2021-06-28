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

import WidgetKit
import SwiftUI
import Foundation

struct WidgetStyle {
    static func getStyle(widgetFamily: WidgetFamily = .systemSmall) -> (
        contentPaddingBottom: CGFloat,
        contentPaddingTrailing: CGFloat,
        contentPaddingLeading: CGFloat,
        
        titleFontSize: CGFloat,
        titleMaxLines: Int,
        
        dateFontSize: CGFloat,
        dateMaxLines: Int) {
        switch widgetFamily {
        case .systemMedium:
            return (10, 10, 10, 20, 3, 14, 2)
        default:
            return (10, 10, 10, 15, 3, 12, 2)
        }
    }
    
    static func getLogoSize() -> CGFloat {
        return 130.0
    }
    
    static func getLogoOffset(widgetFamily: WidgetFamily) -> (x: CGFloat, y: CGFloat) {
        switch widgetFamily {
        
        default:
            return (getLogoSize() * 0.4, -1*getLogoSize()*0.4)
        }
    }
}
