//
//  ReadController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ReadController: ThemeController {
    let animator = PopupTransitionAnimator()
    
    
    var presenter: ReadPresenterProtocol?
    var collectionNode: ASPagerNode { return node as! ASPagerNode }
    
    var lessonInfo: LessonInfo?
    var reads = [Read]()
    
    var shouldHideStatusBar = false
    var lastContentOffset: CGFloat = 0
    var lastCellNode = false
    var lastPageIndex = 0
    var lastTapLocation: CGPoint = CGPoint.zero
    
    
    var t = false
    
    init() {
        super.init(node: ASPagerNode())
        self.collectionNode.backgroundColor = .baseGray1
        self.collectionNode.setDataSource(self)
        self.collectionNode.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        presenter?.configure()
        setTransparentNavigation()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        gestureRecognizer.delegate = self
        
        let gestureRecognizerPan = UIPanGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        gestureRecognizerPan.delegate = self
        
        self.collectionNode.view.addGestureRecognizer(gestureRecognizer)
        self.collectionNode.view.addGestureRecognizer(gestureRecognizerPan)
        
        automaticallyAdjustsScrollViewInsets = false
        
        let rightButton = UIBarButtonItem(image: R.image.iconNavbarFont(), style: .done, target: self, action: #selector(readingOptions(sender:)))
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UITapGestureRecognizer || gestureRecognizer is UIPanGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.hideBottomHairline()
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func readingOptions(sender: UIBarButtonItem) {
        let buttonView = sender.value(forKey: "view") as! UIView
        let size = CGSize(width: round(node.frame.width)-10, height: 167)
        
        animator.style = .arrow
        animator.fromView = buttonView
        animator.interactive = false
        
        presenter?.presentReadOptionsScreen(size: size, transitioningDelegate: animator)
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
    
    func scrollBehavior(scrollView: UIScrollView){
        
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height {
            if (-scrollView.contentOffset.y <= UIApplication.shared.statusBarFrame.height + navigationBarHeight){
                readNavigationBarStyle(color: .tintColor)
            } else {
                setTransparentNavigation()
            }
        }
        
        if (scrollView.contentOffset.y + UIScreen.main.bounds.height >= scrollView.contentSize.height){
            if let navigationController = navigationController, navigationController.isNavigationBarHidden {
                toggleBars()
            }
        } else {
            if (-scrollView.contentOffset.y > 0 || lastContentOffset < -scrollView.contentOffset.y){
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
        }
        
        lastContentOffset = -scrollView.contentOffset.y
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let contextMenuNode = (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.contextMenu
        if (contextMenuNode?.isHidden != true){
            contextMenuNode!.view.frame = CGRect(origin: self.lastTapLocation, size: contextMenuNode!.view.frame.size)
        }
    }

    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer){
        self.lastTapLocation = recognizer.location(in: recognizer.view?.superview)
        
        let view = recognizer.view
        let loc = recognizer.location(in: view)
        let subview = view?.hitTest(loc, with: nil) // note: it is a `UIView?`

        let contextMenuNode = (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.contextMenu
        
        if (subview != contextMenuNode!.view){
            if (contextMenuNode?.isHidden != true){
                contextMenuNode?.isHidden = true
            }
        }
    }
    
    func evaluateJavascriptOnAllWebViews(command: String){
        (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.webView.stringByEvaluatingJavaScript(from: command)
        
        for webViewIndex in 0...self.reads.count {
            if self.collectionNode.currentPageIndex == webViewIndex { continue }
            
            (self.collectionNode.nodeForPage(at: webViewIndex) as? ReadView)?.webView.stringByEvaluatingJavaScript(from: command)
        }
    }
    
    func readNavigationBarStyle(color: UIColor = .tintColor){
        let theme = currentTheme()
        if theme == ReaderStyle.Theme.Dark {
            setTranslucentNavigation(true, color: .readerDark, tintColor: .readerDarkFont, titleColor: .readerDarkFont)
        } else {
            setTranslucentNavigation(true, color: color, tintColor: .white, titleColor: .white)
        }
    }
}

extension ReadController: ReadControllerProtocol {
    func loadLessonInfo(lessonInfo: LessonInfo){
        self.lessonInfo = lessonInfo
        title = lessonInfo.lesson.title.uppercased()
    }
    
    func showRead(read: Read) {
        self.reads.append(read)
        self.collectionNode.reloadData()
    }
}

extension ReadController: ASPagerDataSource {
    func pagerNode(_ pagerNode: ASPagerNode, nodeBlockAt index: Int) -> ASCellNodeBlock {
        let read = reads[index]
        
        let cellNodeBlock: () -> ASCellNode = {
            let node = ReadView(lessonInfo: self.lessonInfo!, read: read, delegate: self)
            
            return node
        }
        
        return cellNodeBlock
    }
    
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        if lessonInfo != nil && !reads.isEmpty {
            return reads.count
        }
        return 0
    }
}

extension ReadController: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        lastPageIndex = self.collectionNode.indexOfPage(with: node)
        scrollBehavior(scrollView: (node as! ReadView).webView.scrollView)
    }
}

extension ReadController: ReadViewDelegate {
    func didScrollView(readCellNode: ReadView, scrollView: UIScrollView) {
        if (self.collectionNode.indexOfPage(with: readCellNode as ASCellNode) != lastPageIndex) {
            return
        }
        scrollBehavior(scrollView: scrollView)
    }
    
    func didClickVerse(read: Read, verse: String) {
        let size = CGSize(width: round(node.frame.width*0.9), height: round(node.frame.height*0.8))
        
        animator.style = .square
        
        presenter?.presentBibleScreen(read: read, verse: verse, size: size, transitioningDelegate: animator)
    }
    
    func didLoadWebView(webView: UIWebView){
        let theme = currentTheme()
        let typeface = currentTypeface()
        let size = currentSize()
        
        if !theme.isEmpty {
            webView.stringByEvaluatingJavaScript(from: "ssReader.setTheme('"+theme+"')")
        }
        
        if !typeface.isEmpty {
            webView.stringByEvaluatingJavaScript(from: "ssReader.setFont('"+typeface+"')")
        }
        
        if !size.isEmpty {
            webView.stringByEvaluatingJavaScript(from: "ssReader.setSize('"+size+"')")
        }
        
        UIView.animate(withDuration: 0.3) {
            webView.alpha = 1
        }
    }
    
    func doShowContextMenu(){
        let contextMenuNode = (self.collectionNode.nodeForPage(at: self.collectionNode.currentPageIndex) as? ReadView)?.contextMenu
        contextMenuNode?.isHidden = false
        
        var origin = CGPoint(x: self.lastTapLocation.x - (contextMenuNode!.view.frame.size.width / 2), y: self.lastTapLocation.y - (contextMenuNode!.view.frame.size.height + 20))
        
        if origin.x < 0 {
            origin.x = 0
        }
        
        if origin.y < 0 {
            origin.y = 0
        }
        
        contextMenuNode!.view.frame = CGRect(origin: origin, size: contextMenuNode!.view.frame.size)
    }
}

extension ReadController: ReadOptionsDelegate {
    func didSelectTheme(theme: String) {
        readNavigationBarStyle()
        evaluateJavascriptOnAllWebViews(command: "ssReader.setTheme('"+theme+"')")
    }
    
    func didSelectTypeface(typeface: String){
        evaluateJavascriptOnAllWebViews(command: "ssReader.setFont('"+typeface+"')")
    }
    
    func didSelectSize(size: String){
        evaluateJavascriptOnAllWebViews(command: "ssReader.setSize('"+size+"')")
    }
}
