//
//  CheckmarkAnimationView.swift
//  Sabbath School
//
//  Created by Eugene Fozekosh on 10.02.2025.
//  Copyright © 2025 Adventech. All rights reserved.
//

import SwiftUI

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        //Draw checkmark shape
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.3))
        return path
    }
}

struct CheckmarkAnimationView: View {
    @State private var drawProgress: CGFloat = 0
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.gray.opacity(0.8))
            CheckmarkShape()
                .trim(from: 0, to: drawProgress)
                .stroke(Color.green,
                        style: StrokeStyle(lineWidth: 7,
                                           lineCap: .round,
                                           lineJoin: .round))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                drawProgress = 1
            }
        }
    }
}
