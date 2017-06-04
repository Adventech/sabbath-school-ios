//
//  ReadCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

protocol ReadCellNodeDelegate {
    func didScrollView(readCellNode: ReadCellNode, scrollView: UIScrollView)
    func didClickVerse(read: Read, verse: String)
}

class ReadCellNode: ASCellNode {
    var delegate: ReadCellNodeDelegate
    let coverNode = ASNetworkImageNode()
    let textNode = ASTextNode()
    let webNode = ASDisplayNode { UIWebView() }
    let reader = Reader()
    var read: Read?
    
    var initialCoverNodeHeight: CGFloat = 0
    var parallaxCoverNodeHeight: CGFloat = 0
    
    var webView: UIWebView { return webNode.view as! UIWebView }
    
    init(lessonInfo: LessonInfo, read: Read, delegate: ReadCellNodeDelegate) {
        self.delegate = delegate
        super.init()
        self.read = read
        
        coverNode.url = lessonInfo.lesson.cover
        coverNode.contentMode = .scaleAspectFill
        coverNode.backgroundColor = UIColor.tintColor
        coverNode.imageModificationBlock = { image in
            image.tint(tintColor: .tintColor)
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
        
        initialCoverNodeHeight = coverNode.calculatedSize.height

        webView.backgroundColor = .clear
        webView.scrollView.contentInset = UIEdgeInsets(top: initialCoverNodeHeight, left: 0, bottom: 0, right: 0)
        webView.scrollView.delegate = self
        webView.delegate = self
        
        reader.loadReadContent(read: read!)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height*0.4)
        webNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        
        let layoutSpec = ASAbsoluteLayoutSpec(
            sizing: .sizeToFit,
            children: [coverNode, webNode]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: layoutSpec)
    }
}

extension ReadCellNode: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate.didScrollView(readCellNode: self, scrollView: scrollView)
        
        if coverNode.image != nil {
            self.parallaxCoverNodeHeight = -scrollView.contentOffset.y
            self.setNeedsLayout()
        }
    }
}

extension ReadCellNode: ReaderOutputProtocol {
    func didLoadReadContent(content: String) {
        webView.loadHTMLString(content, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }
    func didPrepareChangeTheme(theme: String) {
        print(theme)
    }
}

extension ReadCellNode: UIWebViewDelegate {
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
