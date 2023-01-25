/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

class DevotionalFeedBookView: ASCellNode {
    private let resource: Resource
    private let image: RoundedCornersImage
    private let title = ASTextNode()
    private let subtitle = ASTextNode()
    private var inline: Bool
    
    init(resource: Resource, inline: Bool = false) {
        self.inline = inline
        self.resource = resource
        image = RoundedCornersImage(
            imageURL: resource.cover,
            corner: 4.0,
            size: nil,
            backgroundColor: .black
        )
        super.init()
        self.selectionStyle = .none
        title.attributedText = AppStyle.Devo.Text.resourceListTitle(string: resource.title)
        subtitle.attributedText = AppStyle.Devo.Text.resourceListSubtitle(string: resource.subtitle ?? "")
        subtitle.maximumNumberOfLines = 2
        
        image.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        image.shadowOffset = CGSize(width: 0, height: 2)
        image.shadowRadius = 10
        image.shadowOpacity = 0.3
        image.clipsToBounds = false
        
        clipsToBounds = false
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        image.style.preferredSize = CGSize(width: 100, height: 140)

        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: [title]
        )
        
        if resource.subtitle != nil {
            vSpec.children?.insert(subtitle, at: 0)
        }
        
        let mainSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 20,
            justifyContent: .start,
            alignItems: .center,
            children: [image, vSpec]
        )
        
        vSpec.style.flexShrink = 1.0
        mainSpec.style.flexGrow = 1.0
        mainSpec.style.preferredSize = CGSize(width: 300, height: 140)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: inline ? 20 : 0, bottom: 15, right: inline ? 20 : 0), child: mainSpec)
    }
    
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? AppStyle.Lesson.Color.backgroundHighlighted : AppStyle.Lesson.Color.background }
    }
}
