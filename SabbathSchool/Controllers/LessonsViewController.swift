//
//  LessonsViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import Unbox

final class LessonsViewController: BaseTableViewController {
    var database: FIRDatabaseReference!
    var quarterlyInfo: QuarterlyInfo?
    
    // MARK: - Init
    
    init(quarterlyIndex: String) {
        super.init()
        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Lesson".uppercased()
        backgroundColor = UIColor.tintColor
        
        database = FIRDatabase.database().reference()
        database.keepSynced(true)
        
        // Load data
        loadQuarterlyInfo(quarterlyIndex: quarterlyIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButtom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tableNode.view.contentOffset.y >= 30 {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    //
    
    func loadQuarterlyInfo(quarterlyIndex: String) {
        database.child(Constants.Firebase.quarterlyInfo).child(quarterlyIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
            
            do {
                let item: QuarterlyInfo = try unbox(dictionary: json)
                self.quarterlyInfo = item
                
                if let color = item.quarterly.colorPrimary {
                    self.backgroundColor = UIColor.init(hex: color)
                    self.view.window?.tintColor = UIColor.init(hex: color)
                } else {
                    self.backgroundColor = .baseGreen
                }
                
                self.tableNode.view.reloadSections(IndexSet(arrayLiteral: 0, 1), with: .fade)
            } catch let error {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

// MARK: - ASTableDataSource

extension LessonsViewController: ASTableDataSource {
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let quarterlyInfo = quarterlyInfo else {
            let cellNodeBlock: () -> ASCellNode = { return ASCellNode() }
            return cellNodeBlock
        }
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.section == 0 {
                let node = FeaturedLessonCellNode(
                    title: quarterlyInfo.quarterly.title,
                    subtitle: quarterlyInfo.quarterly.humanDate,
                    detail: quarterlyInfo.quarterly.description,
                    cover: quarterlyInfo.quarterly.cover
                )
                
                if let color = quarterlyInfo.quarterly.colorPrimary {
                    node.backgroundColor = UIColor.init(hex: color)
                } else {
                    node.backgroundColor = .baseGreen
                }
                
                return node
            }
            
            let lesson = quarterlyInfo.lessons[indexPath.row]
            let node = LessonCellNode(
                title: lesson.title,
                subtitle: "\(lesson.startDate.stringLessonDate()) - \(lesson.endDate.stringLessonDate())",
                number: "\(indexPath.row+1)"
            )
            return node
        }
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lessons = quarterlyInfo?.lessons else { return 0 }
        return section == 0 ? 1 : lessons.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

// MARK: - ASTableDelegate

extension LessonsViewController: ASTableDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lesson = quarterlyInfo?.lessons[indexPath.row] else { return }
        let reader = ReadsViewController(lessonIndex: lesson.index)
        show(reader, sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 30 {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
}
