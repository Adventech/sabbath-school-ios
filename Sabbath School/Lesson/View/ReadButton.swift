/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
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
import AsyncDisplayKit

enum ReadButtonState: Int {
    case download = 0
    case downloading = 1
    case downloaded = 2
}

final class ReadButton: ASDisplayNode {
    
    let readButton = ASButtonNode()
    let line = ASDisplayNode()
    let downloadButton = ASButtonNode()

    override init() {
        super.init()
        readButton.setAttributedTitle(AppStyle.Lesson.Text.readButton(string: "Read".localized().uppercased()), for: .normal)
        readButton.accessibilityIdentifier = "readLesson"
        readButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 20)
        line.backgroundColor = .white
        
        downloadButton.style.preferredSize = CGSize(width: 15.12, height: 30)
        downloadButton.imageNode.style.preferredSize = CGSize(width: 15.12, height: 30)
        downloadButton.imageNode.contentMode = .scaleAspectFit
        downloadButton.contentEdgeInsets = .init(top: 12, left: 0, bottom: 8, right: 0)
        
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        line.style.preferredSize = CGSize(width: 1, height: 32)
        downloadButton.style.preferredSize = CGSize(width: 22.67, height: 30)

        let vSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .start,
            alignItems: .start,
            children: [readButton, line, downloadButton]
        )

        vSpec.style.flexShrink = 1.0

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 8), child: vSpec)
    }
    
    func setState(_ state: ReadButtonState) {
        switch state {
        case .downloaded:
            downloadButton.setImage(R.image.iconDownloaded(), for: .normal)
        case .download:
            downloadButton.setImage(R.image.iconDownload(), for: .normal)
        case .downloading:
            downloadButton.setImage(R.image.iconDownloading(), for: .normal)
        }
    }
}
