//
//  WidgetStyle.swift
//  WidgetExtension
//
//  Created by Vitaliy Lim on 2021-06-20.
//  Copyright © 2021 Adventech. All rights reserved.
//

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
