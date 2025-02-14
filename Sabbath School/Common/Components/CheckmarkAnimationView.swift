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

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0.27 * w, y: 0.53 * h))
        path.addLine(to: CGPoint(x: 0.42 * w, y: 0.68 * h))
        path.addLine(to: CGPoint(x: 0.72 * w, y: 0.38 * h))
        
        return path
    }
}

struct CheckmarkAnimationView: View {
    @State private var checkmarkTrim: CGFloat = 0.0
    private let hudSize: CGFloat = 100
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .frame(width: hudSize, height: hudSize)
            CheckmarkShape()
                .trim(from: 0, to: checkmarkTrim)
                .stroke(Color.white,
                        style: StrokeStyle(lineWidth: 4,
                                           lineCap: .round,
                                           lineJoin: .round))
                .frame(width: hudSize * 0.7, height: hudSize * 0.7)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                checkmarkTrim = 1.0
            }
        }
    }
}
