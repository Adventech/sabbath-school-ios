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

class DocumentHeadNode: ASCellNode {
    private let imageNode = ASNetworkImageNode()
    private let subtitleNode = ASTextNode()
    public let titleNode = ASTextNode()
    
    private let title: String
    private let subtitle: String?
    private let image: URL?
    
    public init(title: String, subtitle: String?, image: URL? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        super.init()
        automaticallyManagesSubnodes = true
        titleNode.attributedText = AppStyle.Markdown.Text.Head.title(string: title)
        subtitleNode.attributedText = AppStyle.Markdown.Text.Head.subtitle(string: subtitle ?? "")
        imageNode.url = image
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 300)
        
        let headSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode]
        )
        
        if subtitle != nil {
            headSpec.children?.insert(subtitleNode, at: 0)
        }
        
        let titleSubtitleSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: image != nil ? 0 : 140, left: 15, bottom: 30, right: 15), child: headSpec)
        
        if image != nil {
            return ASStackLayoutSpec(
                direction: .vertical,
                spacing: 10,
                justifyContent: .start,
                alignItems: .start,
                children: [imageNode, titleSubtitleSpec]
            )
        }
        
        return titleSubtitleSpec
    }
}
