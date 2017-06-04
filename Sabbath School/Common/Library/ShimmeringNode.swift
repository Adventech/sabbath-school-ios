//
//  ShimmeringNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import Shimmer

final class ShimmeringNode: ASDisplayNode {
    
    init(didLoadBlock: ((ShimmeringNode) -> Void)? = nil) {
        super.init()
        setViewBlock({FBShimmeringView()})
        onDidLoad { (node) in
            didLoadBlock?(node as! ShimmeringNode)
        }
        isOpaque = false
    }
    
    var contentNode: ASDisplayNode? {
        didSet {
            if contentNode != nil {
                applyContentNode()
            } else {
                contentNode?.removeFromSupernode()
            }
        }
    }
    
    override var view: FBShimmeringView {
        return super.view as! FBShimmeringView
    }
    
    override func didLoad() {
        super.didLoad()
        applyContentNode()
    }
    
    private func applyContentNode() {
        guard let contentNode = self.contentNode else { return }
        addSubnode(contentNode)
        if isNodeLoaded {
            view.contentView = contentNode.view
        }
    }
}
