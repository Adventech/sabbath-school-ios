/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import AsyncDisplayKit
import SwiftDate
import UIKit
import WebKit

protocol ReadViewOutputProtocol: AnyObject {
    func didTapCopy()
    func didTapShare()
    func didTapLookup()
    func didTapClearHighlight()
    func didTapHighlight(color: String)
    func didClickVerse(read: Read, verse: String)
    func didScrollView(readCellNode: ReadView, scrollView: UIScrollView)
    func didLoadWebView(webView: WKWebView)
    func didReceiveHighlights(readHighlights: ReadHighlights)
    func didReceiveComment(readComments: ReadComments)
    func didReceiveCopy(text: String)
    func didReceiveShare(text: String)
    func didReceiveLookup(text: String)
    func didTapExternalUrl(url: URL)
}

class ReadView: ASCellNode {
    weak var delegate: ReadViewOutputProtocol?
    let cover = ASNetworkImageNode()
    let coverOverlay = ASDisplayNode()
    let title = ASTextNode()
    let date = ASTextNode()

    let webNode = ASDisplayNode { Reader() }
    var read: Read?
    var highlights: ReadHighlights?
    var comments: ReadComments?

    var initialCoverHeight: CGFloat = 0
    var parallaxCoverHeight: CGFloat = 0

    var webView: Reader { return webNode.view as! Reader }

    init(lessonInfo: LessonInfo, read: Read, delegate: ReadViewOutputProtocol) {
        self.delegate = delegate
        super.init()
        self.read = read
    
        self.highlights = ReadHighlights(readIndex: read.index, highlights: "")
        self.comments = ReadComments(readIndex: read.index, comments: [Comment]())

        cover.url = lessonInfo.lesson.cover
        cover.placeholderEnabled = true
        cover.placeholderFadeDuration = 0.6
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        coverOverlay.alpha = 0

        title.alpha = 1
        title.maximumNumberOfLines = 2
        title.pointSizeScaleFactors = [0.9, 0.8]
        title.attributedText = AppStyle.Read.Text.title(string: read.title)

        date.alpha = 1
        date.maximumNumberOfLines = 1
        date.attributedText = AppStyle.Read.Text.date(string: read.date.stringReadDate())
        
        
        automaticallyManagesSubnodes = true
    }
    
    func parallax() {
        if self.parallaxCoverHeight >= 0 {
            self.coverOverlay.alpha = 1 - ((self.parallaxCoverHeight-80) * (1/(self.initialCoverHeight-80)))

            if self.parallaxCoverHeight <= self.initialCoverHeight {
                self.cover.frame.origin.y -= (self.initialCoverHeight - parallaxCoverHeight) / 2
                self.title.frame.origin.y -= (self.initialCoverHeight - parallaxCoverHeight) / 1.3
                self.title.alpha = self.parallaxCoverHeight * (1/self.initialCoverHeight)

                self.date.frame.origin.y -= (self.initialCoverHeight - parallaxCoverHeight) / 1.3
                self.date.alpha = self.parallaxCoverHeight * (1/self.initialCoverHeight)
                
                let topInset = coverOverlay.frame.size.height * parallaxCoverHeight * 1/initialCoverHeight
                webView.scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
            } else {
                self.coverOverlay.frame.size = CGSize(width: coverOverlay.calculatedSize.width, height: parallaxCoverHeight)
                self.cover.frame.size = CGSize(width: cover.calculatedSize.width, height: parallaxCoverHeight)

                self.title.alpha = 1-((self.parallaxCoverHeight - self.title.frame.origin.y) - 200)/self.title.frame.origin.y*1.6
                self.title.frame.origin.y += (parallaxCoverHeight - self.initialCoverHeight)

                self.date.alpha = self.title.alpha
                self.date.frame.origin.y += (parallaxCoverHeight - self.initialCoverHeight)
            }
        }
    }

    override func layout() {
        super.layout()
        parallax()
    }
    
    override func didLoad() {
        super.didLoad()

        let theme = Preferences.currentTheme()
        cover.backgroundColor = theme.navBarColor
        coverOverlay.backgroundColor = theme.navBarColor
        
        if #available(iOS 13.0, *) {
            webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = true
        } else if #available(iOS 11.0, *){
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }

        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInset = UIEdgeInsets(top: initialCoverHeight, left: 0, bottom: 0, right: 0)
        webView.scrollView.contentOffset.y = -self.parallaxCoverHeight
        // webView.scrollView.setNeedsLayout()

        webView.readerViewDelegate = self
        webView.loadContent(content: read!.content)
        
        webView.scrollView.scrollToTop(animated: true)
        parallax()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        initialCoverHeight = constrainedSize.max.height*0.4
        cover.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width), ASDimensionMake(constrainedSize.max.height*0.4))
        webNode.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width), ASDimensionMake(constrainedSize.max.height))
        
        DispatchQueue.main.async {
            let isPlaying = AudioPlayback.shared.playerState == .playing
            self.webView.scrollView.contentInset.bottom = isPlaying ? 50 : 0
        }
        title.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width-40), ASDimensionMake(.auto, 0))
        date.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width-40), ASDimensionMake(.auto, 0))

        let titleDateSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .end,
            alignItems: .center,
            children: [date, title]
        )

        titleDateSpec.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width), ASDimensionMake(constrainedSize.max.height*0.4-20))

        let coverOverlaySpec = ASOverlayLayoutSpec(child: cover, overlay: ASAbsoluteLayoutSpec(children: [titleDateSpec, coverOverlay]))

        let layoutSpec = ASAbsoluteLayoutSpec(
            sizing: .sizeToFit,
            children: [coverOverlaySpec, webNode]
        )

        return layoutSpec
    }
}

extension ReadView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.didScrollView(readCellNode: self, scrollView: scrollView)

        self.parallaxCoverHeight = -scrollView.contentOffset.y
        self.setNeedsLayout()
    }
}

extension ReadView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let r = webView as! Reader
        if r.shouldStartLoad(request: navigationAction.request, navigationType: navigationAction.navigationType) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        (webView as! Reader).contextMenuEnabled = true
        webView.becomeFirstResponder()
        self.delegate?.didLoadWebView(webView: webView)
    }

    func didFinishNavigation(_ webView: WKWebView) {
        

//        if !webView.isLoading {
//
//
//        }
    }
}

extension ReadView: ReaderOutputProtocol {
    func ready() {
        
        if self.highlights != nil {
            webView.setHighlights((self.highlights?.highlights)!)
        }

        guard let comments = self.comments?.comments, !comments.isEmpty else { return }

        for comment in comments {
            webView.setComment(comment)
        }
    }

    func didLoadContent(content: String) {}

    func didTapClearHighlight() {
        self.delegate?.didTapClearHighlight()
    }

    func didTapCopy() {
        self.delegate?.didTapCopy()
    }

    func didTapShare() {
        self.delegate?.didTapShare()
    }
    
    func didTapLookup() {
        self.delegate?.didTapLookup()
    }

    func didTapHighlight(color: String) {
        self.delegate?.didTapHighlight(color: color)
    }

    func didClickVerse(verse: String) {
        self.delegate?.didClickVerse(read: self.read!, verse: verse)
    }

    func didReceiveHighlights(highlights: String) {
        self.delegate?.didReceiveHighlights(readHighlights: ReadHighlights(readIndex: (read?.index)!, highlights: highlights))
    }

    func didReceiveComment(comment: String, elementId: String) {
        var found = false
        guard let comments = comments?.comments else { return }

        for (index, readComment) in comments.enumerated() where readComment.elementId == elementId {
            found = true
            self.comments?.comments[index].comment = comment
        }

        if !found {
            self.comments?.comments.append(Comment(elementId: elementId, comment: comment))
        }

        self.delegate?.didReceiveComment(readComments: self.comments!)
    }

    func didReceiveCopy(text: String) {
        self.delegate?.didReceiveCopy(text: text)
    }

    func didReceiveShare(text: String) {
        self.delegate?.didReceiveShare(text: text)
    }
    
    func didReceiveLookup(text: String) {
        self.delegate?.didReceiveLookup(text: text)
    }

    func didTapExternalUrl(url: URL) {
        self.delegate?.didTapExternalUrl(url: url)
    }
}
