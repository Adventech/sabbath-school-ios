//
//  QuarterTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class QuarterViewController: BaseTableViewController {
    private(set) var state: State = .empty
    
    // MARK: - Init
    
    override init() {
        super.init()
        tableNode.delegate = self
        tableNode.dataSource = self
        
        self.title = "Sabbath School".uppercased()
        
        backgroundColor = UIColor.init(hex: "#B30558")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: - NavBar Actions
    
    func didTapOnSettings(_ sender: AnyObject) {
        
    }
    
    func didTapOnFilter(_ sender: AnyObject) {
        
    }
}

// MARK: - ASTableDataSource

extension QuarterViewController: ASTableDataSource {

    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.row == 0 {
                let node = CurrentQuarterCellNode(title: "The Book of Job", subtitle: "First quarter 2016", cover: URL(string: "https://s3-us-west-2.amazonaws.com/com.cryart.sabbathschool/en/2016-04/cover.png"))
                node.backgroundColor = self.backgroundColor
                return node
            }
            
            let node = QuarterCellNode(title: "Rebelion and Redemption", subtitle: "First quarter 2016", detail: "Many people struggle with the age-old question, If God exists, and is so good, so loving, and so powerful, why so much suffering? Hence, this quarterâ€™s study: the book of Job", cover: URL(string: "https://s3-us-west-2.amazonaws.com/com.cryart.sabbathschool/en/2016-04/cover.png"))
            return node
        }
        
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.itemCount
    }
}

// MARK: - ASTableDelegate

extension QuarterViewController: ASTableDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lessonList = LessonsViewController()
        show(lessonList, sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 30 {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
}
