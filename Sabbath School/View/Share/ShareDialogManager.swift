/*
 * Copyright (c) 2025 Adventech <info@adventech.io>
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

import SwiftUI
import SwiftEntryKit

struct ShareDialogManager {
    let shareOptions: ShareOptions
    
    func showShareDialog(resource: Resource) {
        showShareDialog(featuredTitle: resource.title, featuredColor: Color(hex: resource.primaryColorDark))
    }
    
    func showShareDialog(document: ResourceDocument) {
        showShareDialog(featuredTitle: document.title, featuredColor: .baseBlue)
    }
    
    internal func showShareDialog(featuredTitle: String, featuredColor: Color) {
        let hostingController = ShareDialogControllerWrapper(
            rootView: ShareDialog(
                shareOptions: shareOptions,
                featuredTitle: featuredTitle,
                featuredColor: featuredColor
            )
        )
        
        hostingController.view.layer.cornerRadius = 6
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        SwiftEntryKit.display(entry: hostingController, using: Animation.shareDialogue(widthRatio: 0.9, heightRatio: 0.4, backgroundColor: .clear, hasKeyboard: true))
    }
}
