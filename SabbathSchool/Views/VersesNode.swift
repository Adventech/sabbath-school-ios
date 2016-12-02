//
//  VersesNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class VersesNode: ASDisplayNode {
    let webNode = ASDisplayNode { UIWebView() }
    var webView: UIWebView { return webNode.view as! UIWebView }
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        usesImplicitHierarchyManagement = true
    }
    
    override func didLoad() {
        webView.backgroundColor = UIColor.white
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: webNode)
    }
}
