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

class BibleVersionView: ASCellNode {
    let name = ASTextNode()
    let active = ASImageNode()

    init(name: String, isSelected: Bool) {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        self.isSelected = isSelected
        self.name.attributedText = AppStyle.Bible.Text.title(string: name)
        self.active.image = R.image.iconCheckmark()?.imageTintColor(AppStyle.Base.Color.controlActive2)
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 2,
            justifyContent: .start,
            alignItems: .start,
            children: [name]
        )

        var hSpecChildren: [ASLayoutElement] = [vSpec]

        if isSelected {
            hSpecChildren.append(active)
        }

        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: hSpecChildren
        )

        hSpec.style.alignSelf = .stretch

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15), child: hSpec)
    }
    
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? AppStyle.Lesson.Color.backgroundHighlighted : AppStyle.Lesson.Color.background }
    }
}
