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

struct TextNodeV4: View {
    
    let bibleVerses: [BibleVerses]
    let text: String
    var didTapLink: (([BibleVerses], String) -> Void)?
    
    var body: some View {
        let markdown = try! AttributedString(markdown: text, options: .init(allowsExtendedAttributes: true))
        Text(markdown)
            .environment(\.openURL, OpenURLAction(handler: handleURL))
            .environment(\.font, Font(R.font.latoMedium(size: 19)!))
            .environment(\.lineSpacing, 3)
            .accentColor(Color(uiColor: UIColor.baseBlue))
            .foregroundColor(
                Color(uiColor: AppStyle.Quarterly.Color.introduction)
            )
    }
    
    func handleURL(_ url: URL) -> OpenURLAction.Result {
        if url.absoluteString.starts(with: "sspmBible://"),
            let startIndex = url.absoluteString.range(of: "sspmBible://") {
            didTapLink?(bibleVerses, String(url.absoluteString[startIndex.upperBound...]))
        }
        
        return .handled
    }
}

struct TextNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        TextNodeV4(bibleVerses: [], text: "A disciple is not above his teacher, but everyone who is perfectly trained will be like his teacher” ([Luke 6:40](sspmBible://Luke640)). This one short statement outlines the object of the Christian life. The goal of every true disciple is to be like Jesus.")
    }
}
