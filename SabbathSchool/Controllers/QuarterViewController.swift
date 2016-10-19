//
//  QuarterTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

struct State {
    var itemCount: Int
    var fetchingMore: Bool
    static let empty = State(itemCount: 5, fetchingMore: false)
}

final class QuarterViewController: ASViewController<ASDisplayNode> {
    var tableNode: ASTableNode { return node as! ASTableNode}
    var backgroundColor: UIColor!
    private(set) var state: State = .empty
    fileprivate var isAnimating = false
    
    // MARK: - Init
    
    init() {
        super.init(node: ASTableNode())
        
        // 
        backgroundColor = UIColor.baseBlue
        
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
        
        self.title = "Sabbath School".uppercased()
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
//            tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight-barHeight, left: 0, bottom: 0, right: 0)
//            tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight+barHeight)
        }
    }
    
    // MARK: - NavBar Actions
    
    func didTapOnSettings(_ sender: AnyObject) {
        
    }
    
    func didTapOnFilter(_ sender: AnyObject) {
        
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
        self.setTranslucentNavigation(true, color: backgroundColor, tintColor: UIColor.white, titleColor: UIColor.white, andFont: R.font.latoMedium(size: 15)!)
    }
    
    func hideNavigationBar() {
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
        self.setTransparentNavigation()
    }
    
    // MARK: - Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Animation delegate

extension QuarterViewController: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        isAnimating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
}

// MARK: - ASTableDataSource

extension QuarterViewController: ASTableDataSource {

    func tableView(_ tableView: ASTableView, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.row == 0 {
            let node = CurrentQuarterCellNode(title: "The Book of Job", subtitle: "First quarter 2016", cover: URL(string: "https://s3-us-west-2.amazonaws.com/com.cryart.sabbathschool/en/2016-04/cover.png"))
            node.backgroundColor = backgroundColor
            return node
        }
        
        let node = QuarterCellNode(title: "Rebelion and Redemption", subtitle: "First quarter 2016", detail: "Many people struggle with the age-old question, If God exists, and is so good, so loving, and so powerful, why so much suffering? Hence, this quarterâ€™s study: the book of Job", cover: URL(string: "https://s3-us-west-2.amazonaws.com/com.cryart.sabbathschool/en/2016-04/cover.png"))
        return node
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.itemCount
    }
}

// MARK: - ASTableDelegate

extension QuarterViewController: ASTableDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 30 {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
}
