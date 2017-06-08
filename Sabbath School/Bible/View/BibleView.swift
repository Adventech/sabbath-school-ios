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
    let webNode = ASDisplayNode { UIWebView() }
    var webView: UIWebView { return webNode.view as! UIWebView }
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        webView.backgroundColor = UIColor.white
        webView.delegate = self
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: webNode)
    }
}

extension BibleView: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        let theme = currentTheme()
        let typeface = currentTypeface()
        let size = currentSize()
        
        if !theme.isEmpty {
            webView.stringByEvaluatingJavaScript(from: "ssReader.setTheme('"+theme+"')")
        }
        
        if !typeface.isEmpty {
            webView.stringByEvaluatingJavaScript(from: "ssReader.setFont('"+typeface+"')")
        }
        
        if !size.isEmpty {
            webView.stringByEvaluatingJavaScript(from: "ssReader.setSize('"+size+"')")
        }
    }
}
