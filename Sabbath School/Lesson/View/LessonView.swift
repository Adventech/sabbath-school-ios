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

import AsyncDisplayKit
import UIKit

class LessonView: ASCellNode {
    let title = ASTextNode()
    let dateRange = ASTextNode()
    let index = ASTextNode()

    init(lesson: Lesson, number: String) {
        super.init()
        self.selectionStyle = .none
        backgroundColor = AppStyle.Base.Color.background
        title.attributedText = AppStyle.Lesson.Text.title(string: lesson.title)
        dateRange.attributedText = AppStyle.Lesson.Text.dateRange(string: lesson.dateRange)
        index.attributedText = AppStyle.Lesson.Text.index(string: number)

        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [title, dateRange]
        )

        vSpec.style.flexShrink = 1.0

        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .center,
            children: [index, vSpec]
        )

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
    
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? AppStyle.Lesson.Color.backgroundHighlighted : AppStyle.Lesson.Color.background }
    }
}
