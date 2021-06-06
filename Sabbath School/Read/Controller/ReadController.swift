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
import SafariServices
import UIKit

class ReadController: ThemeController {
    var presenter: ReadPresenterProtocol?
    var collectionNode: ASPagerNode { return node as! ASPagerNode }
    
    var previewingContext: UIViewControllerPreviewing? = nil

    var lessonInfo: LessonInfo?
    var reads = [Read]()
    var highlights = [ReadHighlights]()
    var comments = [ReadComments]()
    var finished: Bool = false
    var processing: Bool = false

    var shouldHideStatusBar = false
    var lastContentOffset: CGFloat = 0
    var initialContentOffset: CGFloat = 0
    var lastPage: Int?
    var isTransitionInProgress: Bool = false
    
    var menuItems = [UIMenuItem]()

    override init() {
        super.init(node: ASPagerNode())
        collectionNode.backgroundColor = AppStyle.Base.Color.background
        collectionNode.setDataSource(self)
        collectionNode.delegate = self
        collectionNode.allowsAutomaticInsetsAdjustment = true
        collectionNode.autoresizesSubviews = true
        collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        collectionNode.automaticallyRelayoutOnSafeAreaChanges = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        presenter?.configure()
        setTransparentNavigation()

        for scrollGestureRecognizer in self.collectionNode.view.gestureRecognizers! {
            guard previewingContext == nil else { continue }
            
            scrollGestureRecognizer.require(toFail: (self.navigationController?.interactivePopGestureRecognizer)!)
        }

        let rightButton = UIBarButtonItem(image: R.image.iconNavbarFont(), style: .done, target: self, action: #selector(readingOptions(sender:)))
        rightButton.accessibilityIdentifier = "themeSettings"
        navigationItem.rightBarButtonItem = rightButton
        UIApplication.shared.isIdleTimerDisabled = true

        if #available(iOS 11.0, *) {
            self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.hideBottomHairline()
        scrollBehavior()

        if let webView = (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.webView {
            webView.setupContextMenu()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    @objc func readingOptions(sender: UIBarButtonItem) {
        var size = CGSize(width: round(node.frame.width)-10, height: 167)
        
        if Helper.isPad {
            size.width = round(node.frame.width*0.4) < 400 ? 400 : round(node.frame.width*0.4)
        }

        presenter?.presentReadOptionsScreen(size: size, sourceView: sender)
    }

    func toggleBars() {
        let shouldHide = !navigationController!.isNavigationBarHidden
        shouldHideStatusBar = shouldHide
        updateAnimatedStatusBar()
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }

    func updateAnimatedStatusBar() {
        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }

    func scrollBehavior() {
        guard finished || !reads.isEmpty else { return }
        guard let readView = collectionNode.nodeForPage(at: collectionNode.currentPageIndex) as? ReadView else { return }
        let scrollView = readView.webView.scrollView

        if let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height {
            if -scrollView.contentOffset.y <= UIApplication.shared.statusBarFrame.height + navigationBarHeight {
                title = readView.read?.title.uppercased()
                readNavigationBarStyle(titleColor: UIColor.white.withAlphaComponent(1-(-scrollView.contentOffset.y-navigationBarHeight)/navigationBarHeight))
            } else {
                title = ""
                setTransparentNavigation()
            }
        }

        let offset = scrollView.contentOffset.y + UIScreen.main.bounds.height
        if offset >= scrollView.contentSize.height {
            if let navigationController = navigationController, navigationController.isNavigationBarHidden {
                toggleBars()
            }
        } else {
            guard #available(iOS 11.0, *) else {
                if (-scrollView.contentOffset.y > 0) || (lastContentOffset < -scrollView.contentOffset.y) {
                    if let navigationController = navigationController, navigationController.isNavigationBarHidden {
                        toggleBars()
                    }
                } else {
                    if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
                        if scrollView.panGestureRecognizer.state != .possible {
                            toggleBars()
                        }
                    }
                }
                lastContentOffset = -scrollView.contentOffset.y
                return
            }
        }
        lastContentOffset = -scrollView.contentOffset.y
    }

    func readNavigationBarStyle(titleColor: UIColor = .white) {
        let theme = Preferences.currentTheme()
        setTranslucentNavigation(
            color: theme.navBarColor,
            tintColor: theme.navBarTextColor,
            titleColor: theme == .dark ? theme.navBarTextColor : titleColor
        )
        collectionNode.backgroundColor = theme.backgroundColor

        for webViewIndex in 0...self.reads.count {
            guard let readView = collectionNode.nodeForPage(at: webViewIndex) as? ReadView else { return }
            readView.coverOverlay.backgroundColor = theme.navBarColor
            readView.cover.backgroundColor = theme.navBarColor
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.isTransitionInProgress = true
        super.viewWillTransition(to: size, with: coordinator)
        collectionNode.frame.size = size
        collectionNode.relayoutItems()
        collectionNode.waitUntilAllUpdatesAreProcessed()
        collectionNode.reloadData()
    
        DispatchQueue.main.async {
            self.collectionNode.scrollToPage(at: self.lastPage!, animated: false)
            self.isTransitionInProgress = false
        }
    }
}

extension ReadController: ReadControllerProtocol {
    func loadLessonInfo(lessonInfo: LessonInfo) {
        self.lessonInfo = lessonInfo
    }

    func showRead(read: Read, highlights: ReadHighlights, comments: ReadComments, finish: Bool) {
        self.reads.append(read)
        self.highlights.append(highlights)
        self.comments.append(comments)

        guard finish else { return }
        self.finished = finish
        self.collectionNode.reloadData()

        // Scrolls to the current day
        let today = Date()
        let cal = Calendar.current
        for (readIndex, read) in reads.enumerated().prefix(7) where cal.compare(today, to: read.date, toGranularity: .day) == .orderedSame {
            DispatchQueue.main.async {
                self.collectionNode.scrollToPage(at: readIndex, animated: false)
                self.lastPage = readIndex
            }
        }
    }
}

extension ReadController: ASPagerDataSource {
    func pagerNode(_ pagerNode: ASPagerNode, nodeBlockAt index: Int) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {

            if !self.finished {
                return ReadEmptyView()
            }
            
            let read = self.reads[index]
            let readHighlights = self.highlights[index]
            let readComments = self.comments[index]
            
            return ReadView(lessonInfo: self.lessonInfo!, read: read, highlights: readHighlights, comments: readComments, delegate: self)
        }

        return cellNodeBlock
    }

    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        if finished && (lessonInfo != nil && !reads.isEmpty) {
            return reads.count
        }
        return 1
    }
}

extension ReadController: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        if !isTransitionInProgress {
            lastPage = self.collectionNode.indexOfPage(with: node)
        }
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollBehavior()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollBehavior()
    }
}

extension ReadController: ReadViewOutputProtocol {
    func didTapCopy() {
        (collectionNode.nodeForPage(at: collectionNode.currentPageIndex) as! ReadView).webView.copyText()
    }

    func didTapShare() {
        (collectionNode.nodeForPage(at: collectionNode.currentPageIndex) as! ReadView).webView.shareText()
    }
    
    func didTapLookup() {
        (collectionNode.nodeForPage(at: collectionNode.currentPageIndex) as! ReadView).webView.lookupText()
    }

    func didTapClearHighlight() {
        (collectionNode.nodeForPage(at: collectionNode.currentPageIndex) as! ReadView).webView.clearHighlight()
    }

    func didTapHighlight(color: String) {
        (collectionNode.nodeForPage(at: collectionNode.currentPageIndex) as! ReadView).webView.highlight(color: color)
    }

    func didScrollView(readCellNode: ReadView, scrollView: UIScrollView) {
        scrollBehavior()
    }

    func didClickVerse(read: Read, verse: String) {
        let size = CGSize(width: round(node.frame.width*0.9), height: round(node.frame.height*0.8))
        presenter?.presentBibleScreen(read: read, verse: verse, size: size)
        UIMenuController.shared.menuItems = []
    }

    func didLoadWebView(webView: UIWebView) {
        if abs(webView.scrollView.contentOffset.y) > 0 {
            initialContentOffset = -webView.scrollView.contentOffset.y
        }
        UIView.animate(withDuration: 0.3) {
            webView.alpha = 1
        }
    }

    func didReceiveHighlights(readHighlights: ReadHighlights) {
        presenter?.interactor?.saveHighlights(highlights: readHighlights)
    }

    func didReceiveComment(readComments: ReadComments) {
        presenter?.interactor?.saveComments(comments: readComments)
    }

    func didReceiveCopy(text: String) {
        UIPasteboard.general.string = text
    }

    func didReceiveShare(text: String) {
        let objectsToShare: [Any] = [text, self.lessonInfo?.lesson.fullPath ?? ""]
        let activityController = UIActivityViewController(
            activityItems: objectsToShare,
            applicationActivities: nil)

        activityController.popoverPresentationController?.sourceRect = self.view.frame
        activityController.popoverPresentationController?.sourceView = self.view
        if Helper.isPad {
            activityController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        }
        activityController.popoverPresentationController?.permittedArrowDirections = .any

        self.present(activityController, animated: true, completion: nil)
    }
    
    func didReceiveLookup(text: String) {
        DispatchQueue.main.async {
            self.presenter?.presentDictionary(word: text)
        }
    }

    func didTapExternalUrl(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.view.tintColor = AppStyle.Base.Color.tint
        safariVC.modalPresentationStyle = .currentContext
        present(safariVC, animated: true, completion: nil)
    }
}

extension ReadController: ReadOptionsDelegate {
    func didSelectTheme(theme: ReaderStyle.Theme) {
        readNavigationBarStyle()
        for webViewIndex in 0...self.reads.count {
            (self.collectionNode.nodeForPage(at: webViewIndex) as? ReadView)?.webView.setTheme(theme)
        }

        scrollBehavior()
    }

    func didSelectTypeface(typeface: ReaderStyle.Typeface) {
        for webViewIndex in 0...self.reads.count {
            (self.collectionNode.nodeForPage(at: webViewIndex) as? ReadView)?.webView.setTypeface(typeface)
        }
    }

    func didSelectSize(size: ReaderStyle.Size) {
        for webViewIndex in 0...self.reads.count {
            (self.collectionNode.nodeForPage(at: webViewIndex) as? ReadView)?.webView.setSize(size)
        }
    }
}

extension ReadController: BibleControllerOutputProtocol {
    func didDismissBibleScreen() {
        if let webView = (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.webView {
            webView.createContextMenu()
        }
    }
}
