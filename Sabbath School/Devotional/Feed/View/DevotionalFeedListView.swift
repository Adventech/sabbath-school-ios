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

class DevotionalFeedListView: ASCellNode {
    private let resource: Resource
    private let image: RoundedCornersImage
    private let title = ASTextNode()
    private let subtitle = ASTextNode()
    private let buttonNode = ASButtonNode()
    private let groupIndex: Int?
    private let resourceIndex: Int?
    
    public var delegate: DevotionalGroupDelegate?
    
    init(resource: Resource, groupIndex: Int? = nil, resourceIndex: Int? = nil) {
        self.resource = resource
        self.groupIndex = groupIndex
        self.resourceIndex = resourceIndex
        
        image = RoundedCornersImage(
            imageURL: resource.cover,
            corner: 4.0,
            size: nil,
            backgroundColor: .black
        )
        super.init()
        title.attributedText = AppStyle.Devo.Text.resourceListTitle(string: resource.title)
        subtitle.attributedText = AppStyle.Devo.Text.resourceListSubtitle(string: resource.subtitle ?? "")
        
        image.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        image.shadowOffset = CGSize(width: 0, height: 2)
        image.shadowRadius = 10
        image.shadowOpacity = 0.3
        image.clipsToBounds = false
        
        buttonNode.addTarget(self, action: #selector(didPressNode(_:)), forControlEvents: .touchUpInside)
        
        automaticallyManagesSubnodes = true
    }
    
    @objc func didPressNode(_ sender: ASButtonNode) {
        guard let groupIndex = self.groupIndex, let resourceIndex = self.resourceIndex else {
            return
        }
        print("SSDEBUG", self.delegate)
        self.delegate?.didSelectResource(groupIndex: groupIndex, resourceIndex: resourceIndex)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        image.style.preferredSize = CGSize(width: 70, height: 70)
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: [title]
        )
        
        if resource.subtitle != nil {
            vSpec.children?.append(subtitle)
        }
        
        let mainSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [vSpec]
        )
        
        if resource.cover != nil {
            mainSpec.children?.append(image)
        }
        
        vSpec.style.flexShrink = 1.0
        mainSpec.style.width = ASDimensionMake(constrainedSize.max.width)
        mainSpec.style.flexGrow = 1.0
        
        let buttonSpec = ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: mainSpec), background: buttonNode)
        
        return buttonSpec
    }
}
