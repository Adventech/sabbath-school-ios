//
//  ReadCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol ReadViewOutputProtocol {
    func didClickVerse(read: Read, verse: String)
    func didScrollView(readCellNode: ReadView, scrollView: UIScrollView)
    func didLoadWebView(webView: UIWebView)
}

class ReadView: ASCellNode {
    var delegate: ReadViewOutputProtocol
    let coverNode = ASNetworkImageNode()
    let coverOverlayNode = ASDisplayNode()
    let coverTitleNode = ASTextNode()
    
    let webNode = ASDisplayNode { Reader() }
    var read: Read?
    
    var initialCoverNodeHeight: CGFloat = 0
    var parallaxCoverNodeHeight: CGFloat = 0
    
    var webView: Reader { return webNode.view as! Reader }
    
    init(lessonInfo: LessonInfo, read: Read, delegate: ReadViewOutputProtocol) {
        self.delegate = delegate
        super.init()
        self.read = read
        
        coverNode.contentMode = .scaleAspectFill
        
        let theme = currentTheme()
        
        if !(lessonInfo.lesson.cover?.absoluteString ?? "").isEmpty {
            coverNode.url = lessonInfo.lesson.cover
            coverNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
            coverNode.placeholderEnabled = true
            coverNode.placeholderFadeDuration = 0.6
        } else {
            if theme == ReaderStyle.Theme.Dark {
                coverNode.backgroundColor = .readerDark
            } else {
                coverNode.backgroundColor = .tintColor
            }
        }
        
        if theme == ReaderStyle.Theme.Dark {
            coverOverlayNode.backgroundColor = .readerDark
        } else {
            coverOverlayNode.backgroundColor = .tintColor
        }
        
        coverOverlayNode.alpha = 0
        coverTitleNode.alpha = 1
        coverTitleNode.maximumNumberOfLines = 1
        
        coverNode.clipsToBounds = true
        coverTitleNode.attributedText = TextStyles.readTitleStyle(string: read.title)
        
        automaticallyManagesSubnodes = true
    }
    
    override func layout() {
        super.layout()        
        
        if self.parallaxCoverNodeHeight >= 0 {
            self.coverOverlayNode.alpha = 1 - ((self.parallaxCoverNodeHeight-80) * (1/(self.initialCoverNodeHeight-80)))
            
            if self.parallaxCoverNodeHeight <= self.initialCoverNodeHeight {
                self.coverNode.frame.origin.y = self.coverNode.frame.origin.y - (self.initialCoverNodeHeight - parallaxCoverNodeHeight) / 2
                self.coverTitleNode.frame.origin.y = self.coverTitleNode.frame.origin.y - (self.initialCoverNodeHeight - parallaxCoverNodeHeight) / 1.3
                self.coverTitleNode.alpha = self.parallaxCoverNodeHeight * (1/self.initialCoverNodeHeight)
            } else {
                self.coverOverlayNode.frame.size = CGSize(width: coverOverlayNode.calculatedSize.width, height: parallaxCoverNodeHeight)
                self.coverNode.frame.size = CGSize(width: coverNode.calculatedSize.width, height: parallaxCoverNodeHeight)
                self.coverTitleNode.alpha = 1-((self.parallaxCoverNodeHeight - self.coverTitleNode.frame.origin.y) - 101)/self.coverTitleNode.frame.origin.y*1.6
            }
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        initialCoverNodeHeight = coverNode.calculatedSize.height

        webView.backgroundColor = .clear
        webView.scrollView.contentInset = UIEdgeInsets(top: initialCoverNodeHeight, left: 0, bottom: 0, right: 0)
        webView.scrollView.delegate = self
        webView.delegate = self
        webView.alpha = 0
        webView.readerViewDelegate = self
        webView.loadContent(content: read!.content)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height*0.4)
        webNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        coverTitleNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        coverTitleNode.style.layoutPosition = CGPoint(x:0, y:constrainedSize.max.height*0.4-100)

        let coverNodeOverlaySpec = ASOverlayLayoutSpec(child: coverNode, overlay: ASAbsoluteLayoutSpec(children: [coverTitleNode, coverOverlayNode]))
        
        let layoutSpec = ASAbsoluteLayoutSpec(
            sizing: .sizeToFit,
            children: [coverNodeOverlaySpec, webNode]
        )        
        
        return layoutSpec
    }
}

extension ReadView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate.didScrollView(readCellNode: self, scrollView: scrollView)
        
        self.parallaxCoverNodeHeight = -scrollView.contentOffset.y
        self.setNeedsLayout()
    }
}

extension ReadView: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return (webView as! Reader).shouldStartLoad(request: request, navigationType: navigationType)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        (webView as! Reader).setupContextMenu()
        if !webView.isLoading {
            self.delegate.didLoadWebView(webView: webView)
        }
    }
}

extension ReadView: ReaderOutputProtocol {
    func didLoadContent(content: String) {}
    func didTapHighlightGreen() {}
    
    func didClickVerse(verse: String) {
        self.delegate.didClickVerse(read: self.read!, verse: verse)
    }
}
