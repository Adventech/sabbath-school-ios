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

class HoriontallySnappingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left + AppStyle.Quarterly.Size.xInset()

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)

        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)

        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            let itemWidth = Float(layoutAttributes.frame.width)
            let direction: Float = velocity.x > 0 ? 1 : -1
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) + itemWidth * direction { offsetAdjustment = itemOffset - horizontalOffset
            }
        })

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map { $0.copy() } as? [UICollectionViewLayoutAttributes]

        attributes?.reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
            guard $1.representedElementCategory == .cell else { return $0 }
            return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                ($0.0 < $1.0 ? $0.0 : $1.0, $0.1 + $1.1)
            }
        }.values.forEach { minY, line in
            line.forEach {
                $0.frame = $0.frame.offsetBy(
                    dx: 0,
                    dy: minY - $0.frame.origin.y
                )
            }
        }
        return attributes
    }
}

class QuarterlyGroupView: GradientNode {
    let groupName = ASTextNode()
    var collectionNode: ASCollectionNode
    
    let seeAll = ASTextNode()
    let seeAllIcon = ASImageNode()
    init(quarterlyGroup: QuarterlyGroup, skipGradient: Bool = true) {
        let collectionViewLayout = HoriontallySnappingCollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        collectionNode = ASCollectionNode(collectionViewLayout: collectionViewLayout)
        
        super.init(startingAt: CGPoint(x: 0.5, y: 0.0),
                   endingAt: CGPoint(x: 0.5, y: 1.0),
                   with: [AppStyle.Quarterly.Color.gradientStart, skipGradient ? AppStyle.Quarterly.Color.gradientStart : AppStyle.Quarterly.Color.gradientEnd],
                   for: [0.0 , 1.0])
        groupName.maximumNumberOfLines = 1
        groupName.attributedText = AppStyle.Quarterly.Text.groupName(string: quarterlyGroup.name)
        
        seeAll.maximumNumberOfLines = 1
        seeAll.attributedText = AppStyle.Quarterly.Text.seeMore(string: "See All".localized())
        
        seeAllIcon.image = R.image.iconMore()?.fillAlpha(fillColor: AppStyle.Quarterly.Color.seeAllIcon)
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: self.view.frame.height)
        collectionNode.style.spacingAfter = 20
        seeAllIcon.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(6), height: ASDimensionMakeWithPoints(8))
        
        let seeAllSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 7,
            justifyContent: .center,
            alignItems: .center,
            children: [seeAll, seeAllIcon])
        
        let topSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [groupName, seeAllSpec])
        
        topSpec.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width), ASDimensionMake(.auto, 0))
        
        let groupNameSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: AppStyle.Quarterly.Size.xPadding() + AppStyle.Quarterly.Size.xInset(), bottom: 0, right: AppStyle.Quarterly.Size.xPadding() + AppStyle.Quarterly.Size.xInset()), child: topSpec)
        
        groupNameSpec.style.spacingBefore = 20
        groupNameSpec.style.spacingAfter = 0
        
        let mainSpec = ASStackLayoutSpec(
           direction: .vertical,
           spacing: 0,
           justifyContent: .start,
           alignItems: .start,
           children: [groupNameSpec, collectionNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: mainSpec)
    }
}
