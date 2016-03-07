//
//  StretchyTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 04/03/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

class StretchyTableViewController: UITableViewController {
    
    private var isAnimating = false
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
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
        if (navBar?.layer.animationForKey(kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.3
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.addAnimation(animation, forKey: kCATransition)
        }
        self.setTranslucentNavigation(true, color: backgroundColor, tintColor: UIColor.whiteColor(), titleColor: UIColor.whiteColor(), andFont: UIFont.latoMediumOfSize(15))
    }
    
    func hideNavigationBar() {
        if (isAnimating) { return }
        
        let navBar = self.navigationController?.navigationBar
        if (navBar?.layer.animationForKey(kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.3
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.addAnimation(animation, forKey: kCATransition)
        }
        self.setTransparentNavigation()
    }
    
    // MARK: - Animation delegate
    
    override func animationDidStart(anim: CAAnimation) {
        isAnimating = true
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
}
