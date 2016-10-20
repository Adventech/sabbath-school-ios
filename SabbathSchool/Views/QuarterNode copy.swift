//
//  QuarterNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class QuarterNode: ASDisplayNode {
    fileprivate var isAnimating = false
//    var stretchyHeader: StretchyHeader!
    
    let coverNode = ASNetworkImageNode()
    var tableNode: ASTableNode!
    var headerHeight: CGFloat = 0
    var animatingHeaderHeight: CGFloat = 0
    var navigationBarHeight: CGFloat = 0
    
    init(coverURL: URL?) {
        super.init()
        
        usesImplicitHierarchyManagement = true
        
        coverNode.url = coverURL
//        coverNode.image = R.image.illustration()
        coverNode.delegate = self
        
        tableNode = ASTableNode()
        tableNode.backgroundColor = UIColor.clear
        
        tableNode.view.contentInset = UIEdgeInsets(top: navigationBarHeight, left: 0, bottom: 0, right: 0)
        tableNode.view.contentOffset = CGPoint(x: 0, y: navigationBarHeight)
    }
    
    // Stretchy header
    
    func updateHeaderView(scrollView: UIScrollView) {
        if coverNode.image != nil {
            if tableNode.view.contentOffset.y < -tableNode.view.contentInset.top {
                coverNode.contentMode = .scaleAspectFill
                animatingHeaderHeight = -scrollView.contentOffset.y
                self.setNeedsLayout()
            } else if animatingHeaderHeight > 0 {
                coverNode.contentMode = isPad ? .scaleAspectFill : .scaleToFill // Fix size bug
                animatingHeaderHeight = 0
                self.setNeedsLayout()
            }
        }
    }
    
    override func layout() {
        super.layout()
        
        // Animate header height
        if animatingHeaderHeight > 0 {
            coverNode.frame.size = CGSize(width: coverNode.calculatedSize.width, height: animatingHeaderHeight)
        }
    }
    
    func updateInsets() {
        headerHeight = coverNode.calculatedSize.height
//        tableNode.view.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tableNode.view.contentInset = UIEdgeInsets(top: headerHeight-navigationBarHeight, left: 0, bottom: 0, right: 0)
        tableNode.view.contentOffset = CGPoint(x: 0, y: -headerHeight+navigationBarHeight)
    }
    
    //
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        var imageRatio: CGFloat {
//            guard isPhone else { return 0.4 }
//            return coverNode.image != nil ? (coverNode.image?.size.height)! / (coverNode.image?.size.width)! : 0.5
//        }
//        
//        let imagePlace = ASRatioLayoutSpec(ratio: imageRatio, child: coverNode)
        let screen = UIScreen.main.bounds.size
        tableNode.preferredFrameSize = screen
//        tableNode.preferredFrameSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        
        print("size: \(tableNode.preferredFrameSize)")
        
        let hSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
//            children: [imagePlace, tableNode]
            children: [tableNode]
        )
//        let staticSpec = ASStaticLayoutSpec(children: [tableNode, imagePlace])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: hSpec)
    }
}

// MARK: ASNetworkImageNodeDelegate

extension QuarterNode: ASNetworkImageNodeDelegate {
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        if isPhone {
            setNeedsLayout()
        }
        
        updateInsets()
    }
}
