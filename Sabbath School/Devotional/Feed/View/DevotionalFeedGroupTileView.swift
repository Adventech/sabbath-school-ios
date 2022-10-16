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

class DevotionalFeedGroupTileView: ASCellNode, ASCollectionDataSource, ASCollectionDelegate {
    private let title = ASTextNode()
    private var collectionNode: ASCollectionNode
    private let resourceGroup: ResourceGroup
    private let groupIndex: Int
    public var delegate: DevotionalGroupDelegate?
    
    init(groupIndex: Int, resourceGroup: ResourceGroup) {
        self.resourceGroup = resourceGroup
        self.groupIndex = groupIndex
        let collectionViewLayout = HoriontallySnappingCollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionViewLayout.itemSize = CGSize(width: 300, height: 260)
        collectionNode = ASCollectionNode(collectionViewLayout: collectionViewLayout)
        
        title.attributedText = AppStyle.Devo.Text.resourceGroupName(string: resourceGroup.title)
        super.init()
        collectionNode.dataSource = self
        collectionNode.delegate = self
        automaticallyManagesSubnodes = true
        collectionNode.clipsToBounds = false
        clipsToBounds = false
        selectionStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: title), collectionNode]
        )
        collectionNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(260))
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0), child: vSpec)
    }
    
    override func didLoad() {
        super.didLoad()
        collectionNode.view.decelerationRate = .fast
        collectionNode.view.contentInsetAdjustmentBehavior = .never
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.view.backgroundColor = .white | .black
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            return DevotionalFeedTileView(resource: self.resourceGroup.resources[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resourceGroup.resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectResource(groupIndex: groupIndex, resourceIndex: indexPath.row)
    }
}
