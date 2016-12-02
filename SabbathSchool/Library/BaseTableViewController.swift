//
//  SSTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 19/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

struct State {
    var itemCount: Int
    var fetchingMore: Bool
    static let empty = State(itemCount: 5, fetchingMore: false)
}

class BaseTableViewController: ASViewController<ASDisplayNode> {
    var tableNode: ASTableNode { return node as! ASTableNode}
    var backgroundColor: UIColor!
    fileprivate var isAnimating = false

    // MARK: - Init
    
    init() {
        super.init(node: ASTableNode())
        tableNode.view.separatorColor = UIColor.baseSeparator
        tableNode.view.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
            let height = navigationBarHeight+20
            tableNode.view.contentOffset = CGPoint(x: 0, y: -height)
            tableNode.view.contentInset = UIEdgeInsets(top: -height, left: 0, bottom: 0, right: 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Remove selection if exists
        if let selected = tableNode.view.indexPathForSelectedRow {
            tableNode.view.deselectRow(at: selected, animated: true)
        }
    }
    
    // MARK: - Navigation Bar Animation
    
    func showNavigationBar() {
        if (isAnimating) { return }
        
        let navBar = self.navigationController?.navigationBar
        if (navBar?.layer.animation(forKey: kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.2
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.add(animation, forKey: kCATransition)
        }
        setTranslucentNavigation(true, color: backgroundColor, tintColor: .white, titleColor: .white)
    }
    
    func hideNavigationBar() {
        if (isAnimating) { return }
        
        let navBar = self.navigationController?.navigationBar
        if (navBar?.layer.animation(forKey: kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.1
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.add(animation, forKey: kCATransition)
        }
        setTransparentNavigation()
    }
    
    // MARK: - Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Animation delegate

extension BaseTableViewController: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        isAnimating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
}
