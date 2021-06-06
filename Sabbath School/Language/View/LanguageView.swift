/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

class LanguageView: ASDisplayNode {
    let search = ASEditableTextNode()
    let searchBorder = ASDisplayNode()
    let table = ASTableNode()
    
    override init() {
        super.init()
        self.configureStyles()
        
        search.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        search.textView.textContainer.maximumNumberOfLines = 1
        search.maximumLinesToDisplay = 1
        search.scrollEnabled = false
        automaticallyManagesSubnodes = true
    }
    
    func configureStyles() {
        backgroundColor = AppStyle.Base.Color.background
        search.typingAttributes = AppStyle.Language.Text.search()
        search.attributedPlaceholderText = AppStyle.Language.Text.searchPlaceholder(string: "Search…".localized())
        search.backgroundColor = AppStyle.Base.Color.background
        searchBorder.backgroundColor = AppStyle.Base.Color.tableSeparator
        table.view.separatorColor = AppStyle.Base.Color.tableSeparator
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.search.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
        self.searchBorder.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(0.3))
        self.table.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.search.calculatedSize.height, right: 0)
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: [search, searchBorder, table])
    }
}
