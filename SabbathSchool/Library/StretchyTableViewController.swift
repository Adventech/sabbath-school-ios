//
//  StretchyTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 04/03/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

class StretchyTableViewController: UITableViewController {
    
    fileprivate var isAnimating = false
    var stretchyHeader: StretchyHeader!
    var primaryColor: UIColor!
    var secondaryColor: UIColor!
    var backgroundColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarHeight = self.navigationController!.navigationBar.frame.height+20
        stretchyHeader = StretchyHeader(tableView: tableView)
        stretchyHeader.updateOffset(barHeight: navigationBarHeight)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ScrollView Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stretchyHeader.updateHeaderView()
        
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
            if (scrollView.contentOffset.y >= -(stretchyHeader.kTableHeaderCutAway+navigationBarHeight+20)) {
                showNavigationBar()
            } else {
                hideNavigationBar()
            }
        }
    }
    
    // MARK: - Navigation Bar Animation
    
    func showNavigationBar() {
        if (isAnimating) { return }
        
        let navBar = self.navigationController?.navigationBar
        if (navBar?.layer.animation(forKey: kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.3
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.add(animation, forKey: kCATransition)
        }
        self.setTranslucentNavigation(true, color: backgroundColor, tintColor: UIColor.white, titleColor: UIColor.white, andFont: R.font.latoMedium(size: 15)!)
    }
    
    func hideNavigationBar() {
        if (isAnimating) { return }
        
        let navBar = self.navigationController?.navigationBar
        if (navBar?.layer.animation(forKey: kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.3
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.add(animation, forKey: kCATransition)
        }
        self.setTransparentNavigation()
    }
}

// MARK: - Animation delegate

extension StretchyTableViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        isAnimating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
}
