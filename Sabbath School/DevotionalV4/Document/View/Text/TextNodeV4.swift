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

import UIKit
import SwiftUI
import Down

struct TextNodeV4: View {
    
    let font: UIFont
    let bibleVerses: [BibleVerses]
    let text: String
    var didTapLink: (([BibleVerses], String) -> Void)?
    var contextMenuAction: ((ContextMenuAction) -> Void)?
    
    @State private var height: CGFloat = .zero
    
    var body: some View {
        let down = Down(markdownString: text)
        
        let downStylerConfiguration = DownStylerConfiguration(
            fonts: SSPMFontCollection(),
            colors: SSPMColorCollection(),
            paragraphStyles: SSPMParagraphStyleCollection()
        )
        
        let styler = SSPMStyler(configuration: downStylerConfiguration)
        
        // TODO: handle error scenario
        let markdown = try! down.toAttributedString(styler: styler)
        
        ReadViewV4(text: markdown, dynamicHeight: $height, didTapLink: { link in
            didTapLink?(bibleVerses, link)
        }, contextMenuAction: contextMenuAction)
        .accentColor(Color(uiColor: UIColor.baseBlue))
        .frame(height: height)
        .frame(maxWidth: .infinity, idealHeight: height)
    }
}

struct TextNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        TextNodeV4(font: R.font.latoMedium(size: 19)!, bibleVerses: [], text: "A disciple is not above his teacher, but everyone who is perfectly trained will be like his teacher” ([Luke 6:40](sspmBible://Luke640)). This one short statement outlines the object of the Christian life. The goal of every true disciple is to be like Jesus.", contextMenuAction: {_ in })
    }
}
