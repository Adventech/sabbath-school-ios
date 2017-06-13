//
//  ReadCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import SwiftDate
import UIKit

protocol ReadViewOutputProtocol {
    func didTapClearHighlight()
    func didTapHighlight(color: String)
    func didClickVerse(read: Read, verse: String)
    func didScrollView(readCellNode: ReadView, scrollView: UIScrollView)
    func didLoadWebView(webView: UIWebView)
    func didReceiveHighlights(readHighlights: ReadHighlights)
    func didReceiveComment(readComments: ReadComments)
}

class ReadView: ASCellNode {
    var delegate: ReadViewOutputProtocol
    let coverNode = ASNetworkImageNode()
    let coverOverlayNode = ASDisplayNode()
    let coverTitleNode = ASTextNode()
    let readDateNode = ASTextNode()
    
    let webNode = ASDisplayNode { Reader() }
    var read: Read?
    var highlights: ReadHighlights?
    var comments: ReadComments?
    
    var initialCoverNodeHeight: CGFloat = 0
    var parallaxCoverNodeHeight: CGFloat = 0
    
    var webView: Reader { return webNode.view as! Reader }
    
    init(lessonInfo: LessonInfo, read: Read, highlights: ReadHighlights, comments: ReadComments, delegate: ReadViewOutputProtocol) {
        self.delegate = delegate
        super.init()
        self.read = read
        self.highlights = highlights
        self.comments = comments
        
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
        
        coverNode.clipsToBounds = true
        
        coverOverlayNode.alpha = 0
        coverTitleNode.alpha = 1
        coverTitleNode.maximumNumberOfLines = 2
        coverTitleNode.attributedText = TextStyles.readTitleStyle(string: read.title)
        
        readDateNode.alpha = 1
        readDateNode.maximumNumberOfLines = 1
        readDateNode.attributedText = TextStyles.readDateStyle(string: read.date.string(custom: "EEEE, MMMM dd"))
        
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
                
                self.readDateNode.frame.origin.y = self.readDateNode.frame.origin.y - (self.initialCoverNodeHeight - parallaxCoverNodeHeight) / 1.3
                self.readDateNode.alpha = self.parallaxCoverNodeHeight * (1/self.initialCoverNodeHeight)
            } else {
                self.coverOverlayNode.frame.size = CGSize(width: coverOverlayNode.calculatedSize.width, height: parallaxCoverNodeHeight)
                self.coverNode.frame.size = CGSize(width: coverNode.calculatedSize.width, height: parallaxCoverNodeHeight)
                self.coverTitleNode.alpha = 1-((self.parallaxCoverNodeHeight - self.coverTitleNode.frame.origin.y) - 101)/self.coverTitleNode.frame.origin.y*1.6
                self.coverTitleNode.frame.origin.y = self.coverTitleNode.frame.origin.y + (parallaxCoverNodeHeight - self.initialCoverNodeHeight)
                
                self.readDateNode.alpha = self.coverTitleNode.alpha
                self.readDateNode.frame.origin.y = self.readDateNode.frame.origin.y + (parallaxCoverNodeHeight - self.initialCoverNodeHeight)
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
        coverTitleNode.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake("90%"), ASDimensionMake(.auto, 0))
        readDateNode.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake("90%"), ASDimensionMake(.auto, 0))
  
        let titleDateSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .center,
            alignItems: .center,
            children: [coverTitleNode, readDateNode]
        )
        titleDateSpec.style.layoutPosition = CGPoint(x:0, y:constrainedSize.max.height*0.4-130)
        titleDateSpec.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake("100%"), ASDimensionMake(.auto, 0))
        
        let coverNodeOverlaySpec = ASOverlayLayoutSpec(child: coverNode, overlay: ASAbsoluteLayoutSpec(children: [titleDateSpec, coverOverlayNode]))
        
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
        (webView as! Reader).contextMenuEnabled = true
        (webView as! Reader).setupContextMenu()

        if !webView.isLoading {
            self.delegate.didLoadWebView(webView: webView)
        }
    }
}

extension ReadView: ReaderOutputProtocol {
    func ready(){
        if self.highlights != nil {
            webView.setHighlights((self.highlights?.highlights)!)
        }
        
        if !(self.comments?.comments.isEmpty)! {
            for comment in (self.comments?.comments)! {
                webView.setComment(comment)
            }
        }
    }
    
    func didLoadContent(content: String) {}
    
    func didTapClearHighlight() {
        self.delegate.didTapClearHighlight()
    }
    
    func didTapHighlight(color: String) {
        self.delegate.didTapHighlight(color: color)
    }
    
    func didClickVerse(verse: String) {
        self.delegate.didClickVerse(read: self.read!, verse: verse)
    }
    
    func didReceiveHighlights(highlights: String){
        self.delegate.didReceiveHighlights(readHighlights: ReadHighlights(readIndex: (read?.index)!, highlights: highlights))
    }
    
    func didReceiveComment(comment: String, elementId: String){
        var found = false
        for (index, readComment) in (self.comments?.comments.enumerated())! {
            if readComment.elementId == elementId {
                found = true
                
                self.comments?.comments[index].comment = comment
            }
        }
        
        if !found {
            self.comments?.comments.append(Comment(elementId: elementId, comment: comment))
        }
        
        self.delegate.didReceiveComment(readComments: self.comments!)
    }
}
