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

class DevotionalFeedGroupListView: ASCellNode {
    private let resourceGroup: ResourceGroup
    private var resourcesList: [ASLayoutElement] = []
    private let backgroundRect = ASDisplayNode()
    private let header = ASNetworkImageNode()
    private let title = ASTextNode()
    private let groupName = ASTextNode()
    private let groupIndex: Int
    
    public var delegate: DevotionalGroupDelegate? {
        didSet {
            for node in resourcesList {
                if let n = node as? DevotionalFeedListView {
                    n.delegate = self.delegate
                }
            }
        }
    }
    
    init(groupIndex: Int, resourceGroup: ResourceGroup) {
        self.resourceGroup = resourceGroup
        self.groupIndex = groupIndex
        
        super.init()
        
        title.attributedText = AppStyle.About.Text.text(string: "Title")
        
        header.url = resourceGroup.cover
        header.cornerRadius = 4.0
        
        backgroundRect.cornerRadius = 4.0
        backgroundRect.shadowColor = (UIColor(white: 0, alpha: 0.6) | .gray).cgColor
        backgroundRect.shadowOffset = CGSize(width: 0, height: 2)
        backgroundRect.shadowRadius = 10
        backgroundRect.shadowOpacity = 0.3
        backgroundRect.clipsToBounds = false
        backgroundRect.backgroundColor = .white | .baseGray5
        
        groupName.attributedText = AppStyle.Devo.Text.resourceGroupName(string: resourceGroup.title)
        automaticallyManagesSubnodes = true
        
        for (i, resource) in resourceGroup.resources.enumerated() {
            let listNode = DevotionalFeedListView(resource: resource, groupIndex: groupIndex, resourceIndex: i)
            listNode.delegate = delegate
            resourcesList.append(listNode)
            if i != resourceGroup.resources.endIndex-1 {
                let line = ASDisplayNode()
                line.backgroundColor = .baseGray1 | .baseGray4
                line.style.height = ASDimensionMakeWithPoints(1.0)
                resourcesList.append(line)
            }
        }
        
        if resourceGroup.cover != nil {
            resourcesList.insert(header, at: 0)
        }
        
        selectionStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        header.style.height = ASDimensionMakeWithPoints(140)
        
        let groupTable = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .end,
            alignItems: .start,
            children: resourcesList
        )
        
        let tileSpec = ASBackgroundLayoutSpec(
            child: groupTable,
            background: backgroundRect)
        
        tileSpec.style.flexGrow = 1.0
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 20,
            justifyContent: .start,
            alignItems: .start,
            children: [groupName, tileSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), child: mainSpec)
    }
    
    override func layout() {
        super.layout()
        
        if resourceGroup.cover != nil {
            self.header.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
}
