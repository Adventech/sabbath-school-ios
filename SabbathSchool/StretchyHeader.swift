//
//  StretchyHeader.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 03/03/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

class StretchyHeader: NSObject {
    
    let kTableHeaderHeight: CGFloat = 350.0
    let kTableHeaderCutAway: CGFloat = 50.0
    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    var tableView: UITableView!

    // MARK: - Init
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        
        // Configure bounce header
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.blackColor().CGColor
        headerView.layer.mask = headerMaskLayer
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
    
    func updateOffset(barHeight barHeight: CGFloat) {
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight-barHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight+barHeight)
        self.updateHeaderView()
    }
}
