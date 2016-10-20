//
//  QuarterliesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import Unbox

final class QuarterliesViewController: BaseTableViewController {
    var database: FIRDatabaseReference!
    var dataSource = [Quarterly]()
    
    // MARK: - Init
    
    override init() {
        super.init()
        tableNode.delegate = self
        tableNode.dataSource = self
        
        self.title = "Sabbath School".uppercased()
        
        backgroundColor = UIColor.init(hex: "#B30558")
        
        database = FIRDatabase.database().reference()
        database.keepSynced(true)
        
        loadLanguages()
        loadQuarterlies(language: QuarterlyLanguage(code: "en", name: "English"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    //
    
    func loadLanguages() {
        database.child("languages").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
        })
    }
    
    func loadQuarterlies(language: QuarterlyLanguage) {
        database.child("quarterlies").child(language.code).observe(.value, with: { (snapshot) in
            print(snapshot.value)
            
            guard let json = snapshot.value as? [AnyObject] else { return }
            
            do {
                var items = [Quarterly]()
                try json.forEach { item in
                    guard let item = item as? [String: AnyObject] else { return }
                    let object: Quarterly = try unbox(dictionary: item)
                    items.append(object)
                }
                
                self.dataSource = items
                
                self.tableNode.view.beginUpdates()
                self.tableNode.view.reloadData()
                self.tableNode.view.endUpdates()
            } catch let error {
                print(error)
            }
                
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: - NavBar Actions
    
    func didTapOnSettings(_ sender: AnyObject) {
        
    }
    
    func didTapOnFilter(_ sender: AnyObject) {
        
    }
}

// MARK: - ASTableDataSource

extension QuarterliesViewController: ASTableDataSource {

    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let quarterly = dataSource[indexPath.row]
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.row == 0 {
                let node = FeaturedQuarterlyCellNode(
                    title: quarterly.title,
                    subtitle: quarterly.date,
                    cover: URL(string: "https://s3-us-west-2.amazonaws.com/com.cryart.sabbathschool/en/2016-04/cover.png")
                )
                node.backgroundColor = self.backgroundColor
                return node
            }
            
            let node = QuarterlyCellNode(
                title: quarterly.title,
                subtitle: quarterly.date,
                detail: quarterly.description,
                cover: URL(string: "https://s3-us-west-2.amazonaws.com/com.cryart.sabbathschool/en/2016-04/cover.png")
            )
            return node
        }
        
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

// MARK: - ASTableDelegate

extension QuarterliesViewController: ASTableDelegate {
    
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
