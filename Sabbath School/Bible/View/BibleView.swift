//
//  BibleView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class BibleView: ASDisplayNode {
    let webNode = ASDisplayNode { Reader() }
    var webView: Reader { return webNode.view as! Reader }
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        let theme = currentTheme()
        
        if theme == ReaderStyle.Theme.Dark {
            webView.backgroundColor = .readerDark
        } else {
            webView.backgroundColor = .baseGray1
        }
    }
    
    func loadContent(content: String){
        webView.loadContent(content: content)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: webNode)
    }
}
