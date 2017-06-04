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
        
        automaticallyAdjustsScrollViewInsets = false
        
        let rightButton = UIBarButtonItem(image: R.image.iconNavbarFont(), style: .done, target: self, action: #selector(readingOptions(sender:)))
        navigationItem.rightBarButtonItem = rightButton
        
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
                setTranslucentNavigation(true, color: .tintColor, tintColor: .white, titleColor: .white)
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
            let node = ReadCellNode(lessonInfo: self.lessonInfo!, read: read, delegate: self)
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
        scrollBehavior(scrollView: (node as! ReadCellNode).webView.scrollView)
    }
}

extension ReadController: ReadCellNodeDelegate {
    func didScrollView(readCellNode: ReadCellNode, scrollView: UIScrollView) {
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
}
