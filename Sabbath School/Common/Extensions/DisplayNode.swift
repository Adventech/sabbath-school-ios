//
//  DisplayNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

private var shimmeringNodeKey: UInt = 1

extension ASDisplayNode {
    
    var shimmeringNode: ShimmeringNode? {
        get {
            return objc_getAssociatedObject(self, &shimmeringNodeKey) as? ShimmeringNode
        }
        set(newValue) {
            objc_setAssociatedObject(self, &shimmeringNodeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addShimmerToNode(node: ASDisplayNode) {
        if node.shimmeringNode == nil {
            let frame = node.frame
            node.shimmeringNode = ShimmeringNode(didLoadBlock: { shimmeringNode in
                shimmeringNode.view.shimmeringSpeed = frame.size.width
                shimmeringNode.view.shimmeringPauseDuration = 0.1
                shimmeringNode.view.isShimmering = true
            })
            node.shimmeringNode?.frame = frame
            node.shimmeringNode?.contentNode = node
            addSubnode(node.shimmeringNode!)
        }
    }
}
