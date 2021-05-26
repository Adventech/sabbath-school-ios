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
    let searchNode = ASEditableTextNode()
    let searchNodeBorder = ASDisplayNode()
    let tableNode = ASTableNode()
    
    override init() {
        super.init()
        self.backgroundColor = .baseBackground
        self.configureStyles()
        
        searchNode.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        searchNode.textView.textContainer.maximumNumberOfLines = 1
        searchNode.maximumLinesToDisplay = 1
        searchNode.scrollEnabled = false
        automaticallyManagesSubnodes = true
    }
    
    func configureStyles() {
        searchNode.typingAttributes = TextStyles.languageSearchStyle()
        searchNode.attributedPlaceholderText = TextStyles.languageSearchPlaceholderStyle(string: "Search…".localized())
        searchNode.backgroundColor = .baseBackground
        searchNodeBorder.backgroundColor = UIColor.separatorColor()
        tableNode.view.separatorColor = UIColor.separatorColor()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.searchNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
        self.searchNodeBorder.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(0.3))
        self.tableNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        self.tableNode.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.searchNode.calculatedSize.height, right: 0)
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: [searchNode, searchNodeBorder, tableNode])
    }
}
