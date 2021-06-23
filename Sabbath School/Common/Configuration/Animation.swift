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

import Foundation
import SwiftEntryKit

struct Animation {
    static func modalAnimationAttributes(widthRatio: CGFloat = 1, heightRatio: CGFloat = 1, backgroundColor: UIColor = AppStyle.Base.Color.background) -> EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.positionConstraints.size = .init(
            width: EKAttributes.PositionConstraints.Edge.ratio(value: widthRatio),
            height: EKAttributes.PositionConstraints.Edge.ratio(value: heightRatio)
        )
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity
        attributes.roundCorners = .all(radius: 6)
        attributes.entryBackground = .color(color: EKColor(backgroundColor))
        attributes.screenBackground = .color(color: EKColor(UIColor(white: 0, alpha: 0.5)))
        
        attributes.shadow = .active(
            with: .init(
                color: EKColor(Preferences.currentTheme() == .dark ? .white : .black),
                opacity: Preferences.currentTheme() == .dark ? 0.1 : 0.3,
                radius: 10,
                offset: .zero
            )
        )
        attributes.entranceAnimation = .init(
            scale: .init(from: 0.6, to: 1, duration: 0.4, spring: .init(damping: 0.6, initialVelocity: 2)),
            fade: .init(from: 0.3, to: 1, duration: 0.1)
        )
        attributes.entryInteraction = .forward
        attributes.screenInteraction = .dismiss
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.windowLevel = .normal
        return attributes
    }
}
