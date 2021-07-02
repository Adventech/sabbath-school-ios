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

extension ASDisplayNode {
    func gradient(from color1: UIColor, to color2: UIColor) {
        if color1 == color2 { return }
        DispatchQueue.main.async {
            let size = self.view.frame.size
            let width = size.width
            let height = size.height

            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [color1.cgColor, color2.cgColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: width/2, y: 0.0)
            gradient.endPoint = CGPoint(x: width/2, y: 1.0)
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            self.view.layer.insertSublayer(gradient, at: 0)
        }
    }
}

// TODO: Refactor
class HomeCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left + 10

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
}

class QuarterlyGroupView: ASDisplayNode {
    private let skipGradient: Bool
    let groupName = ASTextNode()
    var collectionNode: ASCollectionNode
    
    let seeAll = ASTextNode()
    let seeAllIcon = ASImageNode()

    init(quarterlyGroup: QuarterlyGroup, skipGradient: Bool = true) {
        let collectionViewLayout = HomeCollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        collectionViewLayout.itemSize = CGSize(width: 150 , height: 288)
        collectionNode = ASCollectionNode(collectionViewLayout: collectionViewLayout)
        
        self.skipGradient = skipGradient
        super.init()
        groupName.maximumNumberOfLines = 1
        groupName.attributedText = AppStyle.Quarterly.Text.groupName(string: quarterlyGroup.name)
        
        seeAll.maximumNumberOfLines = 1
        seeAll.attributedText = AppStyle.Quarterly.Text.seeMore(string: "See All".localized())
        
        seeAllIcon.image = R.image.iconMore()?.fillAlpha(fillColor: AppStyle.Quarterly.Color.seeAllIcon)
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        if skipGradient { return }
        self.gradient(from: AppStyle.Quarterly.Color.gradientStart, to: AppStyle.Quarterly.Color.gradientEnd)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.collectionNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 288)
        seeAllIcon.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(6), height: ASDimensionMakeWithPoints(12))
        
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
        
        let groupNameSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20), child: topSpec)
        
        let mainSpec = ASStackLayoutSpec(
           direction: .vertical,
           spacing: 0,
           justifyContent: .start,
           alignItems: .start,
           children: [groupNameSpec, collectionNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: mainSpec)
    }
}
