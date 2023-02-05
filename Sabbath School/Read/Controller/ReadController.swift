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
import SwiftAudio
import AVKit
import PSPDFKit
import PSPDFKitUI

class ReadController: VideoPlaybackDelegatable, TablessViewController {
    var delegate: ReadControllerDelegate?
    var presenter: ReadPresenterProtocol?
    
    private let readCollectionView = ReadCollectionView()
    private var collectionNode: ASPagerNode { return readCollectionView.collectionNode }
    
    var previewingContext: UIViewControllerPreviewing? = nil

    var lessonInfo: LessonInfo?
    private var publishingInfo: PublishingInfo?
    private var audio: [Audio] = []
    private var video: [VideoInfo] = []
    private var reads = [Read]()
    private var highlights = [ReadHighlights]()
    private var comments = [ReadComments]()
    private var finished: Bool = false

    private var shouldHideStatusBar = false
    private var lastContentOffset: CGFloat = 0
    private var initialContentOffset: CGFloat = 0
    private var lastPage: Int?
    private var appeared: Bool = false
    private var isTransitionInProgress: Bool = false
    private var contextMenuEnabled = false
    
    private var menuItems = [UIMenuItem]()
    
    var readIndex: Int?
    
    private var scrollReachedTouchpoint: Bool = false
    
    private var downloader: Downloader?

    override init() {
        super.init(node: readCollectionView)
        collectionNode.setDataSource(self)
        collectionNode.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.paragraphStyle: style]
        
        presenter?.configure()

        UIApplication.shared.isIdleTimerDisabled = true

        collectionNode.view.contentInsetAdjustmentBehavior = .never
        
        readCollectionView.miniPlayerView.play.addTarget(self, action: #selector(didPressPlay(_:)), forControlEvents: .touchUpInside)
        readCollectionView.miniPlayerView.backward.addTarget(self, action: #selector(didPressBackward(_:)), forControlEvents: .touchUpInside)
        readCollectionView.miniPlayerView.close.addTarget(self, action: #selector(didPressClose(_:)), forControlEvents: .touchUpInside)
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentAudioController))
        gesture.numberOfTapsRequired = 1
        
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(presentAudioController))
        swipeGesture.direction = .up
        
        readCollectionView.miniPlayerView.view.isUserInteractionEnabled = true
        readCollectionView.miniPlayerView.view.addGestureRecognizer(gesture)
        readCollectionView.miniPlayerView.view.addGestureRecognizer(swipeGesture)
        
        AudioPlayback.shared.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        handleAudioPlayerStateChange(state: AudioPlayback.shared.playerState)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if UIApplication.shared.applicationState != .background &&
                self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection),
                Preferences.currentTheme() == .auto {
                
                didSelectTheme(theme: ReaderStyle.Theme.auto)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter?.dismissBibleScreen()
    }
    
    @objc func didPressPlay(_ sender: ASButtonNode) {
        if sender.isSelected {
            AudioPlayback.pause()
        } else {
            AudioPlayback.play()
        }
    }
    
    @objc func didPressBackward(_ sender: ASButtonNode) {
        AudioPlayback.shared.seek(to: AudioPlayback.shared.currentTime - 15)
    }
    
    @objc func didPressClose(_ sender: ASImageNode) {
        AudioPlayback.shared.stop()
        self.readCollectionView.miniPlayerShown = false
        self.readCollectionView.transitionLayout(withAnimation: true, shouldMeasureAsync: true)
    }
    
    func showMiniPlayer() {
        self.readCollectionView.miniPlayerShown = true
        self.readCollectionView.transitionLayout(withAnimation: true, shouldMeasureAsync: true)
    }
    
    func updatePlayPauseState(state: AudioPlayerState) {
        if AudioPlayback.shared.currentItem != nil {
            if state == .playing {
                self.showMiniPlayer()
            }
            self.updateAudio()
        }
        
        self.readCollectionView.miniPlayerView.play.isSelected = state == .playing
    }
    
    func updateAudio() {
        if let item = AudioPlayback.shared.currentItem {
            self.readCollectionView.miniPlayerView.title.attributedText = AppStyle.Audio.Text.miniPlayerTitle(string: item.getTitle() ?? "")
            self.readCollectionView.miniPlayerView.artist.attributedText = AppStyle.Audio.Text.miniPlayerArtist(string: item.getArtist() ?? "")
        }
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayer.StateChangeEventData) {
        DispatchQueue.main.async {
            self.updatePlayPauseState(state: state)
            switch state {
            case .loading, .ready:
                self.updateAudio()
            case .playing:
                self.showMiniPlayer()
                self.updateAudio()
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appeared == true {
            self.collectionNode.relayoutItems()
            self.collectionNode.waitUntilAllUpdatesAreProcessed()
            self.collectionNode.reloadData()
            self.collectionNode.scrollToPage(at: self.lastPage ?? 0, animated: false)
        }
        self.appeared = true
    }
    
    private func setupNavigationBar() {
        let theme = Preferences.currentTheme()
        
        setNavigationBarOpacity(alpha: 1)
        self.navigationController?.navigationBar.hideBottomHairline()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(0)]
        self.navigationController?.navigationBar.barTintColor = theme.navBarColor
        readNavigationBarStyle()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
        scrollBehavior()
        setupObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: Setup Observers
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetReader), name: .resetReader, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            if scrollReachedTouchpoint {
                return Preferences.currentTheme() == .dark ? .lightContent : .darkContent
            }
            return .lightContent
        } else {
            return Preferences.currentTheme() == .dark ? .lightContent : scrollReachedTouchpoint ? .default : .lightContent
        }
    }
    
    func statusBarUpdate(light: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    @objc func resetReader() {
        if let webView = (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.webView {
            webView.createContextMenu()
            webView.evaluateJavaScript("ssReader.clearSelection()") { _, error in
                if error != nil {
                    self.collectionNode.reloadData()
                }
            }
        }
    }

    @objc func readingOptions(sender: UIBarButtonItem) {
        var size = CGSize(width: round(node.frame.width)-10, height: 167)
        
        if Helper.isPad {
            size.width = round(node.frame.width*0.4) < 400 ? 400 : round(node.frame.width*0.4)
        }

        presenter?.presentReadOptionsScreen(size: size, sourceView: sender)
    }
    
    @objc func presentAudio(sender: UIBarButtonItem) {
        presentAudioController()
    }
    
    @objc func presentVideo(sender: UIBarButtonItem) {
        let videoController = VideoController(video: self.video, lessonIndex: lessonInfo?.lesson.index, readController: self)
        
        if #available(iOS 13, *) {
            self.present(videoController, animated: true)
        } else {
            self.present(SSNavigationController(rootViewController: videoController), animated: true)
        }
    }
    
    @objc func presentAudioController() {
        var dayIndex: String? = nil
        if let readIndex = lastPage {
            dayIndex = self.reads[safe: readIndex]?.index
        }
        
        let audioController = AudioController(audio: self.audio, lessonIndex: lessonInfo?.lesson.index, dayIndex: dayIndex)
        
        if #available(iOS 13, *) {
            self.present(audioController, animated: true)
        } else {
            self.present(SSNavigationController(rootViewController: audioController), animated: true)
        }
    }
    
    @objc func presentReadMenu(sender: UIBarButtonItem) {
        var readMenuItems: [ReadMenuItem] = [
            ReadMenuItem(
                title: "Original PDF".localized(),
                icon: R.image.iconNavbarPdf()!,
                type: .originalPDF
            ),
            ReadMenuItem(
                title: "Reading Options".localized(),
                icon: R.image.iconNavbarFont()!,
                type: .readOptions
            )
        ]
        
        if publishingInfo != nil {
            let item = ReadMenuItem(
                title: "Get Printed Resources".localized(),
                icon: R.image.arrowCircle()!,
                type: .getPrintedResources
            )
            readMenuItems.append(item)
        }

        let menu = ReadMenuController(items: readMenuItems)
        menu.delegate = self
        
        var size = CGSize(width: round(node.frame.width)*0.6, height: CGFloat(readMenuItems.count) * 51.5 + CGFloat(readMenuItems.count) + (CGFloat(readMenuItems.count) - 1))
        
        if Helper.isPad {
            size.width = round(node.frame.width*0.4) < 400 ? 400 : round(node.frame.width*0.4)
        }
        
        menu.preferredContentSize = size
        menu.modalPresentationStyle = .popover
        menu.modalTransitionStyle = .crossDissolve
        menu.popoverPresentationController?.barButtonItem = sender
        menu.popoverPresentationController?.delegate = menu
        menu.popoverPresentationController?.backgroundColor = AppStyle.Base.Color.background
        menu.popoverPresentationController?.permittedArrowDirections = .up
        present(menu, animated: true, completion: nil)
    }
    
    func displayNavRightButtons() {
        var barButtons: [UIBarButtonItem] = []
        
        if let pdfCount = lessonInfo?.pdfs.count, pdfCount > 0 {
            let rightButton = UIBarButtonItem(image: R.image.iconNavbarMore(), style: .done, target: self, action: #selector(presentReadMenu(sender:)))
            rightButton.accessibilityIdentifier = "additionalSettings"
            barButtons.append(rightButton)
        } else {
            let rightButton = UIBarButtonItem(image: R.image.iconNavbarFont(), style: .done, target: self, action: #selector(readingOptions(sender:)))
            rightButton.accessibilityIdentifier = "themeSettings"
            barButtons.append(rightButton)
        }
        
        if self.video.count > 0 {
            let videoButton = UIBarButtonItem(image: R.image.iconVideo(), style: .done, target: self, action: #selector(presentVideo(sender:)))
            videoButton.accessibilityIdentifier = "videoButton"
            barButtons.append(videoButton)
        }
        
        if self.audio.count > 0 {
            let audioButton = UIBarButtonItem(image: R.image.iconAudio(), style: .done, target: self, action: #selector(presentAudio(sender:)))
            audioButton.accessibilityIdentifier = "audioButton"
            barButtons.append(audioButton)
        }
        
        navigationItem.rightBarButtonItems = barButtons
    }

    func toggleBars() {
        let shouldHide = !navigationController!.isNavigationBarHidden
        shouldHideStatusBar = shouldHide
        updateAnimatedStatusBar()
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
        
        title = readView.read?.title
        
        let theme = Preferences.currentTheme()
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height {
            if -scrollView.contentOffset.y <= UIApplication.shared.statusBarFrame.height + navigationBarHeight {
                let alpha = 1-(-scrollView.contentOffset.y-navigationBarHeight)/navigationBarHeight
                readNavigationBarStyle(titleColor: UIColor.white.withAlphaComponent(alpha))
                
                self.navigationController?.navigationBar.titleTextAttributes =
                    [NSAttributedString.Key.foregroundColor: UIColor.transitionColor(fromColor: UIColor.white.withAlphaComponent(alpha), toColor: theme.navBarTextColor, progress:alpha)]
                    
                self.navigationController?.navigationBar.tintColor = UIColor.transitionColor(fromColor: UIColor.white, toColor: theme.navBarTextColor, progress: alpha)

                setNavigationBarOpacity(alpha: alpha)
                statusBarUpdate(light: alpha < 1)
                scrollReachedTouchpoint = alpha >= 1
                if #available(iOS 13.0, *) {
                    self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
                }
            } else {
                title = ""
                self.navigationController?.navigationBar.tintColor = .white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.navBarTextColor.withAlphaComponent(0)]
                setNavigationBarOpacity(alpha: 0)
                statusBarUpdate(light: true)
                scrollReachedTouchpoint = false
//                if #available(iOS 13.0, *) {
//                    self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.scrollEdgeAppearance
//                }
            }
        }

        let offset = scrollView.contentOffset.y + UIScreen.main.bounds.height
        if offset >= scrollView.contentSize.height {
            if let navigationController = navigationController, navigationController.isNavigationBarHidden {
                toggleBars()
            }
        }
        lastContentOffset = -scrollView.contentOffset.y
    }

    func readNavigationBarStyle(titleColor: UIColor = .white) {
        let theme = Preferences.currentTheme()
        self.navigationController?.navigationBar.barTintColor = theme.navBarColor
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
            self.collectionNode.scrollToPage(at: self.lastPage ?? 1, animated: false)
            self.isTransitionInProgress = false
        }

        if Helper.isPad {
            highlights.forEach { highlight in
                setHighlights(highlights: highlight)
            }
            
            comments.forEach { comment in
                setComments(comments: comment)
            }
        }
    }
    
    private func updateCommentsListWhenRotateIpad(readComments: ReadComments) {
        if Helper.isPad {
            if !comments.filter({ $0.readIndex == readComments.readIndex }).isEmpty {
                for (i, comment) in comments.enumerated() where comment.readIndex == readComments.readIndex {
                    comments[i] = readComments
                }
            } else {
                comments.append(readComments)
            }
        }
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        return [UIPreviewAction(title: "Share".localized(), style: .default, handler: {
            previewAction, viewController in
            if let lesson = self.lessonInfo?.lesson {
                    self.delegate?.shareLesson(lesson: lesson)
                }
        })]
    }
    
    func openPublishingHouse(url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else {
            return
        }

        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .formSheet
        present(safariViewController, animated: true)
    }
}

extension ReadController: ReadMenuControllerDelegate {
    func didSelectMenu(menuItemType: ReadMenuType) {
        switch menuItemType {
        case .originalPDF:
            navigationController?.pushViewController(PDFReadController(lessonIndex: (lessonInfo?.lesson.index)!), animated: true)
        case .readOptions:
            self.readingOptions(sender: (navigationItem.rightBarButtonItems?.first)!)
        case .getPrintedResources:
            openPublishingHouse(url: publishingInfo?.url)
        }
    }
}

extension ReadController: ReadControllerProtocol {
    func loadLessonInfo(lessonInfo: LessonInfo) {
        self.lessonInfo = lessonInfo
        displayNavRightButtons()
    }
    
    func loadAudio(audio: [Audio]) {
        if let lessonIndex = self.presenter?.lessonIndex {
            self.audio = audio.filter { $0.targetIndex.starts(with: lessonIndex) }
        } else {
            self.audio = audio
        }
        
        displayNavRightButtons()
    }
    
    func loadVideo(video: [VideoInfo]) {
        self.video = video
        displayNavRightButtons()
    }

    func showRead(read: Read, finish: Bool) {
        if let index = self.reads.firstIndex(where: { $0.index == read.index }) {
            self.reads[index] = read
            return
        } else {
            self.reads.append(read)
        }

        guard finish else { return }
        self.finished = finish
        
        DispatchQueue.main.async {
            self.collectionNode.reloadData()
        }
        
        if let readIndex = readIndex {
            if 0...self.reads.count ~= readIndex {
                DispatchQueue.main.async {
                    self.collectionNode.scrollToPage(at: readIndex, animated: false)
                    self.lastPage = readIndex
                    self.scrollBehavior()
                }
            }
        } else {
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
        Configuration.reloadAllWidgets()
    }
    
    func setHighlights(highlights: ReadHighlights) {
        if Helper.isPad {
            self.highlights.append(highlights)
        }
        
        if let index = self.reads.firstIndex(where: { $0.index == highlights.readIndex }) {
            if let readView = self.collectionNode.nodeForPage(at: index) as? ReadView {
                readView.highlights = highlights
                readView.webView.setHighlights(highlights.highlights)
            }
        }
    }
    
    func setComments(comments: ReadComments) {
        if let index = self.reads.firstIndex(where: { $0.index == comments.readIndex }) {
            if let readView = self.collectionNode.nodeForPage(at: index) as? ReadView {
                readView.comments = comments
                if !comments.comments.isEmpty {
                    updateCommentsListWhenRotateIpad(readComments: comments)
                }
                for comment in comments.comments {
                    readView.webView.setComment(comment)
                }
            }
        }
    }
    
    func setPublishingInfo(publishingInfo: PublishingInfo?) {
        self.publishingInfo = publishingInfo
    }
}

extension ReadController: ASPagerDataSource {
    func pagerNode(_ pagerNode: ASPagerNode, nodeBlockAt index: Int) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {

            if self.reads.count == 0 {
                return ReadEmptyView()
            }
            
            let read = self.reads[index]
            return ReadView(lessonInfo: self.lessonInfo!, read: read, delegate: self)
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

    func didLoadWebView(webView: WKWebView) {
        if abs(webView.scrollView.contentOffset.y) > 0 {
            initialContentOffset = -1*webView.scrollView.contentOffset.y
        }

        if let reader = webView as? Reader, !contextMenuEnabled {
            contextMenuEnabled = true
            reader.setupContextMenu()
        }
    }

    func didReceiveHighlights(readHighlights: ReadHighlights) {
        if Helper.isPad {
            highlights.append(readHighlights)
        }
        
        presenter?.interactor?.saveHighlights(highlights: readHighlights)
    }

    func didReceiveComment(readComments: ReadComments) {
        updateCommentsListWhenRotateIpad(readComments: readComments)
        presenter?.interactor?.saveComments(comments: readComments)
    }

    func didReceiveCopy(text: String) {
        UIPasteboard.general.string = text
    }

    func didReceiveShare(text: String) {
        guard let day = self.lessonInfo?.days[self.collectionNode.currentPageIndex] else { return }
        var objectsToShare: [Any] = [text, day.webURL]
        if #available(iOS 13.0, *) {
            guard let imageView = (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.cover.image else { return }
            objectsToShare = [ShareItem(title: day.title, subtitle: day.date.stringReadDate(), url: day.webURL, image: imageView, text: text)]
        }
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
