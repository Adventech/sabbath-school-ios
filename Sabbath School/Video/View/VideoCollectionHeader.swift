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

class VideoCollectionHeader: ASCellNode {
    let topIndicator = ASDisplayNode()
    let title = ASTextNode()
    
    override init() {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        
        topIndicator.cornerRadius = 3
        topIndicator.backgroundColor = AppStyle.Audio.Color.topIndicator
        title.attributedText = AppStyle.Quarterly.Text.mainTitle(string: "Video")

        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        topIndicator.style.preferredSize = CGSize(width: 50, height: 5)
        
        let topSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [topIndicator])
        
        topSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        
        title.style.spacingBefore = 20
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [topSpec, title])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20), child: mainSpec)
    }
}
