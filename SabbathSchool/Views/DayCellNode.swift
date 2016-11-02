//
//  DayCellNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 01/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import SafariServices

class DayCellNode: ASCellNode {
    var readerNode: ReaderNode!
    var read: Read!
    
    // MARK: - Init
    
    init(read: Read, cover: URL?) {
        super.init()
        
        self.read = read
        self.backgroundColor = UIColor.white
        
        readerNode = ReaderNode(withCover: cover)
        readerNode.delegate = self
        
        usesImplicitHierarchyManagement = true
    }
    
    override func didLoad() {
        super.didLoad()
        
        let indexPath = Bundle.main.path(forResource: "index", ofType: "html")
        var index = try? String(contentsOfFile: indexPath!, encoding: String.Encoding.utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: read.content)
        index = index?.replacingOccurrences(of: "css/", with: "") // Fix the css path
        index = index?.replacingOccurrences(of: "js/", with: "") // Fix the js path
        
        readerNode.webView.loadHTMLString(index!, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        readerNode.webView.alpha = 0
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        readerNode.preferredFrameSize = constrainedSize.max
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: readerNode)
    }
}

// MARK: ReaderNodeDelegate

private var lastContentOffset: CGFloat = 0

extension DayCellNode: ReaderNodeDelegate {
    
    func readerNode(readerNode: ReaderNode, scrollViewDidScroll scrollView: UIScrollView) {
//        let offset = scrollView.contentOffset.y + UIScreen.main.bounds.height
//
//        if scrollView.contentSize.height <= offset {
//            if let navigationController = navigationController, navigationController.isNavigationBarHidden {
//                toggleBars()
//            }
//        } else if scrollView.contentInset.top > -scrollView.contentOffset.y {
//            if (lastContentOffset > scrollView.contentOffset.y) { // move up
//                if let navigationController = navigationController, navigationController.isNavigationBarHidden {
//                    if scrollView.panGestureRecognizer.state != .possible {
//                        toggleBars()
//                    }
//                }
//            }
//            else if (lastContentOffset < scrollView.contentOffset.y) { // move down
//                if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
//                    if scrollView.panGestureRecognizer.state != .possible {
//                        toggleBars()
//                    }
//                }
//            }
//        }
        
        // update the new position acquired
        lastContentOffset = scrollView.contentOffset.y
    }
    
    func readerNode(readerNode: ReaderNode, scrollViewToPercent percent: CGFloat) {
//        scrollPercent = percent
    }
    
    func readerNode(readerNode: ReaderNode, webViewDidFinishLoad webView: UIWebView) {
        
        // Restore saved position
        //        if let article = article, readerNode.state == .Reader {
        //            readerNode.webView.scrollView.contentOffset = readerNode.convertPercentToPoint(CGFloat(article.progress)/100)
        //        }
    }
    
    func readerNode(readerNode: ReaderNode, segueToURL URL: URL) {
        if #available(iOS 9.0, *) {
//            let safariVC = SFSafariViewController(url: URL)
//            safariVC.view.tintColor = UIColor.tintColor
//            safariVC.modalPresentationStyle = .currentContext
//            present(safariVC, animated: true, completion: nil)
        } else {
            //            let webViewController = WebViewController(url: URL)
            //            let nav = ASNavigationController(rootViewController: webViewController)
            //            nav.view.tintColor = UIColor.tintColor()
            //            nav.modalPresentationStyle = .CurrentContext
            //            presentViewController(nav, animated: true, completion: nil)
        }
    }
}
