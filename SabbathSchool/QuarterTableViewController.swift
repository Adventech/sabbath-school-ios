//
//  QuarterTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

private let kTableHeaderHeight: CGFloat = 350.0
private let kTableHeaderCutAway: CGFloat = 50.0

class QuarterTableViewController: UITableViewController {

    private var isAnimating = false
    var headerMaskLayer: CAShapeLayer!
    var headerView: UIView!
    lazy var navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height+20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sabbath School".uppercaseString

        // Configure bounce header
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight-navigationBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.blackColor().CGColor
        
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as!
        QuarterTableViewCell
        
//        cell.coverImageView.backgroundColor = UIColor.lightGrayColor()
        cell.titleLabel.text = "Rebelion and Redemption"
        cell.subtitleLabel.text = "by Allen Meyer"
        cell.detailLabel.text = "First quarter 2016"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("segueToLesson", sender: indexPath)
    }
    
    // MARK: - ScrollView Delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
        
        if (scrollView.contentOffset.y >= -(kTableHeaderCutAway+navigationBarHeight)) {
            if (!isAnimating) {
                let navBar = self.navigationController?.navigationBar
                if (navBar?.layer.animationForKey(kCATransition) == nil) {
                    let animation = CATransition()
                    animation.duration = 0.3
                    animation.delegate = self
                    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    animation.type = kCATransitionFade
                    navBar?.layer.addAnimation(animation, forKey: kCATransition)
                }
                self.setTranslucentNavigation(true, color: UIColor.hex("#088667"), tintColor: UIColor.whiteColor(), titleColor: UIColor.whiteColor(), andFont: UIFont.latoMediumOfSize(15))
            }
        } else {
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
    }
    
    // MARK: - Animation delegate
    
    override func animationDidStart(anim: CAAnimation) {
        isAnimating = true
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
    
    // MARK: - Update Bounce Header
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
        
        // Cut
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLineToPoint(CGPoint(x: 0, y: headerRect.height-kTableHeaderCutAway))
        headerMaskLayer?.path = path.CGPath
    }

    // MARK: - Status Bar Style

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
