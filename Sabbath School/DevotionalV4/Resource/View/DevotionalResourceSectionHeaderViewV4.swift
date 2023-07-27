/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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

struct DevotionalResourceSectionHeaderViewV4: View {
    
    let colapsedSection: Bool
    let sectionTitle: String?
    var didTap: (() -> Void)?
    
    @State private var isCollapsed = true
    
    var body: some View {
        ViewThatFits {
            HStack {
                Text(AppStyle.Devo.Text.resourceDetailSection(string: sectionTitle?.uppercased() ?? ""))
                    .frame(maxWidth: .infinity ,alignment: .leading)
                if let iconMore = R.image.iconMore(), colapsedSection {
                    Image(uiImage: iconMore.fillAlpha(fillColor: .baseGray2))
                        .rotationEffect(.radians(isCollapsed ? .pi / 2 : .pi * 1.5))
                }
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
        }
        .background(
            Color(AppStyle.Devo.Color.resourceDetailSectionBackground())
        )
        .onTapGesture {
            guard colapsedSection else { return }
            didTap?()
            isCollapsed = !isCollapsed
        }
    }
}

struct DevotionalResourceSectionHeaderViewV4_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalResourceSectionHeaderViewV4(colapsedSection: true, sectionTitle: "Discipleship")
    }
}