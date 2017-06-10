//
//  LessonController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import SwiftDate
import UIKit

final class LessonController: TableController {
    var presenter: LessonPresenterProtocol?
    var dataSource: QuarterlyInfo?
    
    override init() {
        super.init()
        
        tableNode.dataSource = self
        title = "Lesson".uppercased()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        presenter?.configure()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lesson = dataSource?.lessons[indexPath.row] else { return }
        presenter?.presentReadScreen(lessonIndex: lesson.index)
    }
    
    func readButtonAction(sender: OpenButton){
        guard let lesson = dataSource?.lessons[0] else { return }
        
        // TODO: get today's date if within this quarter
        let today = Date()
        for lesson in (dataSource?.lessons)! {
            if today.isAfter(date: lesson.startDate, orEqual: true, granularity: Calendar.Component.day) &&
                today.isBefore(date: lesson.endDate, orEqual: true, granularity: Calendar.Component.day){
                presenter?.presentReadScreen(lessonIndex: lesson.index)
                return
            }
        }
        
        presenter?.presentReadScreen(lessonIndex: lesson.index)
    }
}

extension LessonController: LessonControllerProtocol {
    func showLessons(quarterlyInfo: QuarterlyInfo) {
        self.dataSource = quarterlyInfo
        
        if let colorHex = dataSource?.quarterly.colorPrimary {
            self.colorPrimary = UIColor.init(hex: colorHex)
        }
        self.tableNode.allowsSelection = true
        self.tableNode.reloadData()
        self.colorize()
        self.correctHairline()
    }
}

extension LessonController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        guard let _ = dataSource?.lessons[indexPath.row] else {
            let cellNodeBlock: () -> ASCellNode = {
                
                if indexPath.section == 0 {
                    return QuarterlyEmptyCell()
                }
                
                return LessonEmptyCellNode()
            }
            
            return cellNodeBlock
        }
        
        let lesson = dataSource?.lessons[indexPath.row]
        
        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.section == 0 {
                let node = LessonQuarterlyInfoNode(quarterly: (self.dataSource?.quarterly)!)
                node.readButton.addTarget(self, action: #selector(self.readButtonAction(sender:)), forControlEvents: .touchUpInside)
                return node
            }
            
            return LessonCellNode(lesson: lesson!, number: "\(indexPath.row+1)")
        }
        
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lessons = dataSource?.lessons else {
            return section == 0 ? 1 : 13
        }
        return section == 0 ? 1 : lessons.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
