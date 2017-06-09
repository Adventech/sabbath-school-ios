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
    let coverOverlayNode = ASDisplayNode()
    let coverTitleNode = ASTextNode()
    
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
        } else {
            coverNode.backgroundColor = .tintColor
        }
        
        let theme = currentTheme()
        
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
        
        reader.delegate = self
        
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
        coverTitleNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 80)
        coverTitleNode.style.layoutPosition = CGPoint(x:0, y:constrainedSize.max.height*0.4-100)

        let coverNodeOverlaySpec = ASOverlayLayoutSpec(child: coverNode, overlay: ASAbsoluteLayoutSpec(children: [coverTitleNode, coverOverlayNode]))
        
        let layoutSpec = ASAbsoluteLayoutSpec(
            sizing: .sizeToFit,
            children: [coverNodeOverlaySpec, webNode]
        )
        
        let contextMenuWrapper = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [contextMenu])
        
        return ASBackgroundLayoutSpec(child: contextMenuWrapper, background: layoutSpec)
    }
}

extension ReadView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate.didScrollView(readCellNode: self, scrollView: scrollView)
        
        self.parallaxCoverNodeHeight = -scrollView.contentOffset.y
        self.setNeedsLayout()
    }
}

extension ReadView: ReaderOutputProtocol {
    func didLoadContent(content: String) {
        var content = content
        let theme = currentTheme()
        let typeface = currentTypeface()
        let size = currentSize()
        
        if !theme.isEmpty {
            content = content.replacingOccurrences(of: "ss-wrapper-light", with: "ss-wrapper-"+theme)
        }
        
        if !typeface.isEmpty {
            content = content.replacingOccurrences(of: "ss-wrapper-andada", with: "ss-wrapper-"+typeface)
        }
        
        if !size.isEmpty {
            content = content.replacingOccurrences(of: "ss-wrapper-medium", with: "ss-wrapper-"+size)
        }
        
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
