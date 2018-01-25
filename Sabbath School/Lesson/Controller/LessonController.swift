/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Armchair
import AsyncDisplayKit
import SwiftDate
import UIKit
import StoreKit

final class LessonController: TableController {
    var presenter: LessonPresenterProtocol?
    var dataSource: QuarterlyInfo?
    
    var shouldSkipToReader = false
    

    override init() {
        super.init()

        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        presenter?.configure()
        Armchair.userDidSignificantEvent(true)
        
        if #available(iOS 9.0, *) {
            if self.traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: tableNode.view)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lesson = dataSource?.lessons[indexPath.row] else { return }

        if indexPath.section == 0 {
            openToday()
        } else {
            presenter?.presentReadScreen(lessonIndex: lesson.index)
        }
    }

    func openToday() {
        guard let lesson = dataSource?.lessons[0] else { return }
        let today = Date()
        for lesson in (dataSource?.lessons)! {
            if today.isAfter(date: lesson.startDate, orEqual: true, granularity: Calendar.Component.day) &&
                today.isBefore(date: lesson.endDate, orEqual: true, granularity: Calendar.Component.day) {
                presenter?.presentReadScreen(lessonIndex: lesson.index)
                return
            }
        }
        presenter?.presentReadScreen(lessonIndex: lesson.index)
    }

    func readButtonAction(sender: OpenButton) {
        openToday()
    }
}

extension LessonController: LessonControllerProtocol {
    func showLessons(quarterlyInfo: QuarterlyInfo) {
        self.dataSource = quarterlyInfo

        if let colorHex = dataSource?.quarterly.colorPrimary {
            self.colorPrimary = UIColor(hex: colorHex)
        }
        self.tableNode.allowsSelection = true
        self.tableNode.reloadData()
        self.colorize()
        self.correctHairline()
        
        if shouldSkipToReader {
            openToday()
            //Revert back to default value
            shouldSkipToReader = false
        }
    }
}

@available(iOS 9.0, *)
extension LessonController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let readController = viewControllerToCommit as? ReadController else { return }
        guard let index = readController.lessonInfo?.lesson.index else { return }
        
        readController.previewingContext = previewingContext
        presenter?.presentReadScreen(lessonIndex: index)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableNode.indexPathForRow(at: location) else { return nil }
        guard let lesson = self.dataSource?.lessons[indexPath.row] else { return  nil }
        guard let readController = ReadWireFrame.createReadModule(lessonIndex: lesson.index) as? ReadController else {  return nil }
        readController.previewingContext = previewingContext
        
        return readController
    }
}

extension LessonController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

        guard let lesson = dataSource?.lessons[indexPath.row] else {
            let cellNodeBlock: () -> ASCellNode = {

                if indexPath.section == 0 {
                    return QuarterlyEmptyCell()
                }
                return LessonEmptyCellNode()
            }
            return cellNodeBlock
        }

        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.section == 0 {
                let node = LessonQuarterlyInfoNode(quarterly: (self.dataSource?.quarterly)!)
                node.readButton.addTarget(self, action: #selector(self.readButtonAction(sender:)), forControlEvents: .touchUpInside)
                return node
            }

            return LessonCellNode(lesson: lesson, number: "\(indexPath.row+1)")
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
