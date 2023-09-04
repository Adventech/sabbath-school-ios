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

struct DevotionalReadButtonView: View {
    
    let openButtonTitleText: String
    let openButtonSubtitleText: String?
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                
            }, label: {
                HStack {
                    VStack(spacing: 6) {
                        if let openButtonSubtitleText, !openButtonSubtitleText.isEmpty {
                            Text(AppStyle.Devo.Text.openButtonSubtitle(string: openButtonSubtitleText.uppercased()))
                        }
                        
                        Text(AppStyle.Devo.Text.openButtonTitle(string: openButtonTitleText))
                    }
                    
                    Spacer(minLength: 80)
                    Image(uiImage: R.image.iconMore()!.fillAlpha(fillColor: AppStyle.Quarterly.Color.seeAllIcon))
                }
                
            })
            
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .background(
            )
            .cornerRadius(6)
            .shadow(color: Color(UIColor(white: 0, alpha: 0.6)), radius: 4, x: 0, y: 0)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.75)
    }
}

struct DevotionalReadButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalReadButtonView(openButtonTitleText: "Ler", openButtonSubtitleText: nil)
    }
}
