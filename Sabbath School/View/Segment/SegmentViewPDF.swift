/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
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
import PSPDFKit
import PSPDFKitUI

struct SegmentViewPDF: View {
    var segment: Segment
    var allowHorizontalSwipe: Bool = false
    
    @Binding var showNavigationBarButtons: Bool
    @State private var pdfTabbedViewController: PDFAuxiliaryTabbedViewController?
    
    var body: some View {
        if let pdf = segment.pdf {
            PDFAuxiliaryViewRepresentable(
                pdfs: pdf,
                viewType: allowHorizontalSwipe ? .aux : .segment,
                showNavigationBarButtons: showNavigationBarButtons,
                pdfTabbedViewController: $pdfTabbedViewController
            )
            .toolbar {
                if showNavigationBarButtons {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            (pdfTabbedViewController?.pdfController as? PDFAuxiliaryViewController)?.toggleAnnotations()
                        }) {
                            Image(systemName: "pencil.tip.crop.circle").imageScale(.medium)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            (pdfTabbedViewController?.pdfController as? PDFAuxiliaryViewController)?.toggleOutline()
                        }) {
                            Image(systemName: "bookmark").imageScale(.medium)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            (pdfTabbedViewController?.pdfController as? PDFAuxiliaryViewController)?.toggleSettings()
                        }) {
                            Image(systemName: "gearshape").imageScale(.medium)
                        }
                    }
                }
            }
        }
    }
}
