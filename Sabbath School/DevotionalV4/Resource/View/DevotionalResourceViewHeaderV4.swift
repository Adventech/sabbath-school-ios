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
import Kingfisher

struct DevotionalResourceViewHeaderV4: View {
    
    let resource: Resource
    let openButtonIndex: String
    let openButtonTitleText: String
    let openButtonSubtitleText: String?
    var didTapDocument: ((String) -> Void)?
    
    var body: some View {
        KFImage(resource.splash)
            .frame(width: UIScreen.main.bounds.width ,height: UIScreen.main.bounds.height / 1.5)
            .cornerRadius(4)
            .overlay {
                VStack(spacing: 20) {
                    Spacer()
                    if resource.cover != nil {
                        KFImage(resource.cover)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 225)
                            .cornerRadius(4)
                            .shadow(color: Color(UIColor(white: 0, alpha: 0.6)), radius: 4, x: 0, y: 0)
                    }
                    Text(AppStyle.Devo.Text.resourceDetailTitleForColor(string: resource.title, textColor: UIColor(hex: resource.textColor)))
                    Text(AppStyle.Devo.Text.resourceDetailSubtitleForColor(string: resource.subtitle ?? "", textColor: UIColor(hex: resource.textColor)
                        .withAlphaComponent(0.7))).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    DevotionalReadButtonView(openButtonTitleText: openButtonTitleText).onTapGesture {
                        didTapDocument?(openButtonIndex)
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(
                    EdgeInsets(top: 70, leading: 0, bottom: 40, trailing: 0)
                )
                .background(
                    Color(uiColor: resource.cover != nil ? UIColor(hex: resource.primaryColor) : .clear)
                )
            }
    }
}

struct DevotionalResourceViewHeaderV4_Previews: PreviewProvider {
    static var previews: some View {
        let resource = BlockMockData.generateResource()
        DevotionalResourceViewHeaderV4(resource: resource, openButtonIndex: "", openButtonTitleText: "Ler", openButtonSubtitleText: "")
    }
}
