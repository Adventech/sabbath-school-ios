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

protocol ReadViewOutputProtocol: class {
    func didTapCopy()
    func didTapShare()
    func didTapClearHighlight()
    func didTapHighlight(color: String)
    func didClickVerse(read: Read, verse: String)
    func didScrollView(readCellNode: ReadView, scrollView: UIScrollView)
    func didLoadWebView(webView: UIWebView)
    func didReceiveHighlights(readHighlights: ReadHighlights)
    func didReceiveComment(readComments: ReadComments)
    func didReceiveCopy(text: String)
    func didReceiveShare(text: String)
    func didTapExternalUrl(url: URL)
}

class ReadView: ASCellNode {
    weak var delegate: ReadViewOutputProtocol?
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

        coverNode.url = lessonInfo.lesson.cover
        coverNode.placeholderEnabled = true
        coverNode.placeholderFadeDuration = 0.6
        coverNode.contentMode = .scaleAspectFill
        coverNode.clipsToBounds = true
        coverOverlayNode.alpha = 0

        coverTitleNode.alpha = 1
        coverTitleNode.maximumNumberOfLines = 2
        coverTitleNode.pointSizeScaleFactors = [0.9, 0.8]
        coverTitleNode.attributedText = TextStyles.h1(string: read.title)

        readDateNode.alpha = 1
        readDateNode.maximumNumberOfLines = 1
        readDateNode.attributedText = TextStyles.uppercaseHeader(string: read.date.string(custom: "EEEE, MMMM dd"))

        automaticallyManagesSubnodes = true
    }

    override func layout() {
        super.layout()

        if self.parallaxCoverNodeHeight >= 0 {
            self.coverOverlayNode.alpha = 1 - ((self.parallaxCoverNodeHeight-80) * (1/(self.initialCoverNodeHeight-80)))

            if self.parallaxCoverNodeHeight <= self.initialCoverNodeHeight {
                self.coverNode.frame.origin.y -= (self.initialCoverNodeHeight - parallaxCoverNodeHeight) / 2
                self.coverTitleNode.frame.origin.y -= (self.initialCoverNodeHeight - parallaxCoverNodeHeight) / 1.3
                self.coverTitleNode.alpha = self.parallaxCoverNodeHeight * (1/self.initialCoverNodeHeight)

                self.readDateNode.frame.origin.y -= (self.initialCoverNodeHeight - parallaxCoverNodeHeight) / 1.3
                self.readDateNode.alpha = self.parallaxCoverNodeHeight * (1/self.initialCoverNodeHeight)
            } else {
                self.coverOverlayNode.frame.size = CGSize(width: coverOverlayNode.calculatedSize.width, height: parallaxCoverNodeHeight)
                self.coverNode.frame.size = CGSize(width: coverNode.calculatedSize.width, height: parallaxCoverNodeHeight)

                self.coverTitleNode.alpha = 1-((self.parallaxCoverNodeHeight - self.coverTitleNode.frame.origin.y) - 101)/self.coverTitleNode.frame.origin.y*1.6
                self.coverTitleNode.frame.origin.y += (parallaxCoverNodeHeight - self.initialCoverNodeHeight)

                self.readDateNode.alpha = self.coverTitleNode.alpha
                self.readDateNode.frame.origin.y += (parallaxCoverNodeHeight - self.initialCoverNodeHeight)
            }
        }
    }

    override func didLoad() {
        super.didLoad()

        let theme = currentTheme()
        coverNode.backgroundColor = theme.navBarColor
        coverOverlayNode.backgroundColor = theme.navBarColor

        initialCoverNodeHeight = coverNode.calculatedSize.height

        let bottomSafe = CGFloat(20.0)
        var topPadding = CGFloat(44.0) + bottomSafe

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let safeAreaTop = (window?.safeAreaInsets.top)!
            if safeAreaTop > 0 {
                topPadding += (window?.safeAreaInsets.top)! - bottomSafe
            }
        }

        webView.backgroundColor = .clear
        webView.scrollView.contentInset = UIEdgeInsets(top: initialCoverNodeHeight-CGFloat(topPadding), left: 0, bottom: 0, right: 0)
        webView.scrollView.delegate = self
        webView.delegate = self
        webView.alpha = 0
        webView.readerViewDelegate = self
        webView.loadContent(content: read!.content)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        coverNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height*0.4)
        webNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        coverTitleNode.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width-40), ASDimensionMake(.auto, 0))
        readDateNode.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width-40), ASDimensionMake(.auto, 0))

        let titleDateSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .end,
            alignItems: .center,
            children: [readDateNode, coverTitleNode]
        )

        titleDateSpec.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(constrainedSize.max.width), ASDimensionMake(constrainedSize.max.height*0.4-20))

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
        self.delegate?.didScrollView(readCellNode: self, scrollView: scrollView)

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

        if !webView.isLoading {
            self.delegate?.didLoadWebView(webView: webView)
        }
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

    func didTapExternalUrl(url: URL) {
        self.delegate?.didTapExternalUrl(url: url)
    }
}
