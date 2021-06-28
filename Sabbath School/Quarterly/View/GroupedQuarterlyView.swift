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

class GroupedQuarterlyView: ASCellNode {
    let quarterlyGroup: ASCollectionNode

    override init() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/3 , height: 100)
        collectionViewLayout.scrollDirection = .horizontal
        quarterlyGroup = ASCollectionNode(collectionViewLayout: collectionViewLayout)
        super.init()
        quarterlyGroup.dataSource = self
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        //quarterlyGroup.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        //quarterlyGroup.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(constrainedSize.max.height))
        let mainSpec = ASStackLayoutSpec(
                   direction: .vertical,
                   spacing: 0,
                   justifyContent: .start,
                   alignItems: .start,
                   children: [quarterlyGroup])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: mainSpec)
    }
}

extension GroupedQuarterlyView: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
      let cellNodeBlock = { () -> ASCellNode in
        return QuarterlyEmptyView()
      }
        
      return cellNodeBlock
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
}
