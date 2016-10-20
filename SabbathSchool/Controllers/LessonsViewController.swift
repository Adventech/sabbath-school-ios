//
//  LessonsViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class LessonsViewController: BaseTableViewController {
    private(set) var state: State = .empty
    
    // MARK: - Init
    
    override init() {
        super.init()
        tableNode.delegate = self
        tableNode.dataSource = self
        
        self.title = "Lesson".uppercased()
        
        backgroundColor = UIColor.baseBlue
        
        state = State(itemCount: 14, fetchingMore: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButtom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
}

// MARK: - ASTableDataSource

extension LessonsViewController: ASTableDataSource {
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.row == 0 {
                let node = FeaturedQuarterlyCellNode(title: "The Book of Job", subtitle: "First quarter 2016", cover: URL(string: "https://s3-us-west-2.amazonaws.com/com.cryart.sabbathschool/en/2016-04/cover.png"))
                node.backgroundColor = self.backgroundColor
                return node
            }
            
            let node = LessonCellNode(title: "The Prophetic Calling of Jeremiah", subtitle: "Sep 2 - Oct 2", number: "\(indexPath.row)")
            return node
        }
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.itemCount
    }
}

// MARK: - ASTableDelegate

extension LessonsViewController: ASTableDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 30 {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
}
