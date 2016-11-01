//
//  ReaderNode.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 28/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol ReaderNodeDelegate: class {
    func readerNode(readerNode: ReaderNode, scrollViewDidScroll scrollView: UIScrollView)
    func readerNode(readerNode: ReaderNode, scrollViewToPercent percent: CGFloat)
    func readerNode(readerNode: ReaderNode, webViewDidFinishLoad webView: UIWebView)
    func readerNode(readerNode: ReaderNode, segueToURL URL: URL)
}

class ReaderNode: ASDisplayNode {
    weak var delegate: ReaderNodeDelegate?
    let coverNode = ASNetworkImageNode()
    let readingProgressNode = ASDisplayNode()
    let webNode = ASDisplayNode { UIWebView() }
    var webView: UIWebView { return webNode.view as! UIWebView }
    var headerHeight: CGFloat = 0
    fileprivate var animatingHeaderHeight: CGFloat = 0
    fileprivate var scrollPercent: CGFloat = 0
    fileprivate var readingProgressHeight: CGFloat = 3
    
    // MARK: Init
    
    init(withCover cover: URL?) {
        super.init()
//        self.backgroundColor = ReaderTheme.current.colorForTheme()
        
        
        addSubnode(coverNode)
        
        
        addSubnode(webNode)
        
        // Reading bar
        readingProgressNode.backgroundColor = UIColor.tintColor
        readingProgressNode.alpha = 1
        addSubnode(readingProgressNode)
    }
    
    override func didLoad() {
        // Cover
        coverNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
        coverNode.delegate = self
//        coverNode.url = cover
        coverNode.contentMode = .scaleToFill // Fix size bug
        //            coverNode.addBorder()
        coverNode.placeholderEnabled = true
        coverNode.placeholderFadeDuration = 0.6
        
        // WebView
        webView.backgroundColor = UIColor.clear
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    // MARK: Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imageRatio: CGFloat {
            if isPad {
                return 0.4
            }
            return coverNode.image != nil ? (coverNode.image?.size.height)! / (coverNode.image?.size.width)! : 0.5
        }
        
        let imagePlace = ASRatioLayoutSpec(ratio: imageRatio, child: coverNode)
        
        readingProgressNode.preferredFrameSize = CGSize(width: constrainedSize.max.width, height: readingProgressHeight)
        webNode.preferredFrameSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)

        let staticSpec = ASStaticLayoutSpec(children: [imagePlace, webNode, readingProgressNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: staticSpec)
    }
    
    override func layout() {
        super.layout()
        
        // Animate scroll width
        let barWidth = readingProgressNode.calculatedSize.width * scrollPercent
        readingProgressNode.frame.size = CGSize(width: barWidth, height: readingProgressNode.calculatedSize.height)
        
        // Animate header height
        if animatingHeaderHeight > 0 {
            coverNode.frame.size = CGSize(width: coverNode.calculatedSize.width, height: animatingHeaderHeight)
        }
    }
    
    func updateInsets() {
        headerHeight = coverNode.calculatedSize.height
        let topInset = headerHeight
        webView.scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 44, right: 0)
    }
    
    // MARK: Scroll to Position
    
    func convertPercentToPoint(percent: CGFloat) -> CGPoint {
        let insetTop = webView.scrollView.contentInset.top
        let maximumOffset = webView.scrollView.contentSize.height - webView.scrollView.frame.height
        var actualOffset = maximumOffset * percent
        
        if percent == 0 { actualOffset -= insetTop }
        let offset = CGPoint(x: 0, y: actualOffset)
        return offset
    }
    
    func convertOffsetToPercent() -> CGFloat {
        let maximumOffset = webView.scrollView.contentSize.height - webView.scrollView.frame.height
        let currentOffset = webView.scrollView.contentOffset.y
        let percentage = currentOffset / maximumOffset
        let rangePercent = min(max(percentage, 0), 1)
        return rangePercent
    }
}

// MARK: ASNetworkImageNodeDelegate

extension ReaderNode: ASNetworkImageNodeDelegate {
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        if isPhone {
            setNeedsLayout()
        }
        
        updateInsets()
    }
}

// MARK: UIScrollViewDelegate

extension ReaderNode: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.readerNode(readerNode: self, scrollViewDidScroll: scrollView)
        
        // % of reading
        scrollPercent = convertOffsetToPercent()
        delegate?.readerNode(readerNode: self, scrollViewToPercent: scrollPercent)
        
        if scrollPercent >= 0 {
            self.setNeedsLayout()
        }
        
        // Stretchy header
        if coverNode.image != nil {
            if scrollView.contentOffset.y < -scrollView.contentInset.top {
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
}

// MARK: UIWebViewDelegate

extension ReaderNode: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.3) {
            webView.alpha = 1
        }
        
        // Delegate
        delegate?.readerNode(readerNode: self, webViewDidFinishLoad: webView)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url

        if let scheme = url?.scheme, (scheme == "http" || scheme == "https"), navigationType == .linkClicked {
            delegate?.readerNode(readerNode: self, segueToURL: url!)
            return false
        }
        
        return true
    }
}
