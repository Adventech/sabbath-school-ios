//
//  ReadCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol ReadViewDelegate {
    func didScrollView(readCellNode: ReadView, scrollView: UIScrollView)
    func didClickVerse(read: Read, verse: String)
    func doShowContextMenu()
    func didLoadWebView(webView: UIWebView)
}

class ReadView: ASCellNode {
    var delegate: ReadViewDelegate
    let coverNode = ASNetworkImageNode()
    let textNode = ASTextNode()
    let webNode = ASDisplayNode { ReaderView() }
    let reader = Reader()
    let contextMenu = ReadContextMenuView()
    var read: Read?
    
    var initialCoverNodeHeight: CGFloat = 0
    var parallaxCoverNodeHeight: CGFloat = 0
    
    var webView: ReaderView { return webNode.view as! ReaderView }
    
    init(lessonInfo: LessonInfo, read: Read, delegate: ReadViewDelegate) {
        self.delegate = delegate
        super.init()
        self.read = read
        
        coverNode.contentMode = .scaleAspectFill
        
        if !(lessonInfo.lesson.cover?.absoluteString ?? "").isEmpty {
            coverNode.url = lessonInfo.lesson.cover
            coverNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
            coverNode.placeholderEnabled = true
            coverNode.placeholderFadeDuration = 0.6
            coverNode.imageModificationBlock = { image in
                image.tint(tintColor: .tintColor)
            }
        } else {
            coverNode.backgroundColor = .tintColor
        }
        
        
        coverNode.clipsToBounds = true
        
        textNode.attributedText = TextStyles.cellDetailStyle(string: "hello,world")
        
        reader.delegate = self
        
        automaticallyManagesSubnodes = true
    }
    
    override func layout() {
        super.layout()        
        
        if self.parallaxCoverNodeHeight > 0 {
            if self.parallaxCoverNodeHeight <= self.initialCoverNodeHeight {
                self.coverNode.frame.origin.y = self.coverNode.frame.origin.y - (self.initialCoverNodeHeight - parallaxCoverNodeHeight) / 2
            } else {
                self.coverNode.frame.size = CGSize(width: coverNode.calculatedSize.width, height: parallaxCoverNodeHeight)
            }
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        contextMenu.isHidden = true
        
        initialCoverNodeHeight = coverNode.calculatedSize.height

        webView.backgroundColor = .clear
        webView.scrollView.contentInset = UIEdgeInsets(top: initialCoverNodeHeight, left: 0, bottom: 0, right: 0)
        webView.scrollView.delegate = self
        webView.delegate = self
        webView.alpha = 0
        webView.readerViewDelegate = self
        
        reader.loadContent(content: read!.content)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height*0.4)
        webNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        contextMenu.style.preferredSize = CGSize(width: 300, height: 160)
        
        
        let layoutSpec = ASAbsoluteLayoutSpec(
            sizing: .sizeToFit,
            children: [coverNode, webNode]
        )
        
        let contextMenuWrapper = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [contextMenu])
        
        return ASBackgroundLayoutSpec(child: contextMenuWrapper, background: layoutSpec)
        
//        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: layoutSpec)
    }
}

extension ReadView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate.didScrollView(readCellNode: self, scrollView: scrollView)
        
        if coverNode.image != nil {
            self.parallaxCoverNodeHeight = -scrollView.contentOffset.y
            self.setNeedsLayout()
        }
    }
}

extension ReadView: ReaderOutputProtocol {
    func didLoadContent(content: String) {
        webView.loadHTMLString(content, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }
}

extension ReadView: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !webView.isLoading {
            
            
            
            self.delegate.didLoadWebView(webView: webView)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return false }
        
        if let verse = url.valueForParameter(key: "verse"), let decoded = verse.base64Decode() {
            self.delegate.didClickVerse(read: self.read!, verse: decoded)
            return false
        }
        
        if let scheme = url.scheme, (scheme == "http" || scheme == "https"), navigationType == .linkClicked {
//            delegate?.readerNode(readerNode: self, segueToURL: url)
//            return false
        }
        
        return true
    }
}

extension ReadView: ReaderViewDelegateProtocol {
    func showContextMenu(){
        self.delegate.doShowContextMenu()
    }
}
