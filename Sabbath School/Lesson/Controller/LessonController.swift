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
import UIKit
import StoreKit
import WidgetKit


final class LessonController: TableController {
    var delegate: LessonControllerDelegate?
    var presenter: LessonPresenterProtocol?
    var dataSource: QuarterlyInfo?
    var isPeeking: Bool? = false
    var initiateOpenToday: Bool?
    
    var scrollReachedTouchpoint: Bool = false

    override init() {
        super.init()
        
        tableNode?.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.configure()
        Armchair.userDidSignificantEvent(true)
        
        if #available(iOS 13, *) {} else {
            if self.traitCollection.forceTouchCapability == .available, let view = tableNode?.view {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
        
//        scrollBehavior()
//
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.tintColor = .white
//        setBackButton()
        setupNavigationbar()
    }
//
//    override func viewWillAppear(_ animated: Bool)  {
//        super.viewWillAppear(animated)
//        setupNavigationbar()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setupNavigationbar()
//        scrollBehavior()
//    }
    
    func setupNavigationbar() {
        setNavigationBarOpacity(alpha: 0)
        self.navigationController?.navigationBar.hideBottomHairline()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(0)]
        setBackButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return scrollReachedTouchpoint ? .default : .lightContent
    }
    
    func statusBarUpdate(light: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lesson = dataSource?.lessons[indexPath.row] else { return }

        if indexPath.section == 0 {
            // openToday()
        } else {
            presenter?.presentReadScreen(lessonIndex: lesson.index)
        }
    }
    
    func getTodaysLessonIndex() -> String {
        guard let lessons = dataSource?.lessons else { return "" }
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let hour = Calendar.current.component(.hour, from: today)
        var prevLessonIndex: String? = nil
        
        for lesson in lessons {
            let start = Calendar.current.compare(lesson.startDate, to: today, toGranularity: .day)
            let end = Calendar.current.compare(lesson.endDate, to: today, toGranularity: .day)
            let fallsBetween = ((start == .orderedAscending) || (start == .orderedSame)) && ((end == .orderedDescending) || (end == .orderedSame))

            if fallsBetween {
                if (weekday == 7 && hour < 12 && prevLessonIndex != nil) {
                    return prevLessonIndex!
                } else {
                    return lesson.index
                }
            }
            prevLessonIndex = lesson.index
        }

        if let firstLesson = lessons.first {
            return firstLesson.index
        }
        
        return ""
    }

    func openToday() {
        let todaysLessonIndex = getTodaysLessonIndex()
        if !todaysLessonIndex.isEmpty {
            presenter?.presentReadScreen(lessonIndex: todaysLessonIndex)
        }
    }
    
    func insertShortcutItems(quarterlyInfo: QuarterlyInfo) {
        var shortcutItems = UIApplication.shared.shortcutItems ?? []
        
        let existingIndex = shortcutItems.firstIndex(where: { $0.userInfo?["index"] as? String == quarterlyInfo.quarterly.index })
        
        if existingIndex != nil {
            shortcutItems.remove(at: existingIndex!)
        }

        let shortcutItem = UIApplicationShortcutItem.init(
            type: Constants.DefaultKey.shortcutItem,
            localizedTitle: quarterlyInfo.quarterly.title,
            localizedSubtitle: quarterlyInfo.quarterly.humanDate,
            icon: .init(templateImageName: "icon-bookmark"),
            userInfo: ["index": quarterlyInfo.quarterly.index as NSSecureCoding]
        )
        
        shortcutItems.insert(shortcutItem, at: 0)
        UIApplication.shared.shortcutItems = shortcutItems
    }
    
    func getReadControllerForPeek(indexPath: IndexPath, point: CGPoint) -> ReadController? {
        guard let lessonIndex: String = (indexPath.row == 0 && indexPath.section == 0) ? getTodaysLessonIndex() : self.dataSource?.lessons[indexPath.row].index else { return nil }
        let readController = ReadWireFrame.createReadModule(lessonIndex: lessonIndex)
        readController.delegate = self
        return readController
    }
    
    func scrollBehavior() {
        let mn: CGFloat = 0
        let initialOffset: CGFloat = 200
        
        if self.dataSource == nil { return }
        
        if let dataSource = self.dataSource {
            if dataSource.lessons.count <= 0 { return }
        }
        
        let titleOrigin = (self.tableNode?.nodeForRow(at: IndexPath(row: 0, section: 1)) as! LessonView).view.rectCorrespondingToWindow
        guard let navigationBarMaxY =  self.navigationController?.navigationBar.rectCorrespondingToWindow.maxY else { return }

        var navBarAlpha: CGFloat = (initialOffset - (titleOrigin.minY + mn - navigationBarMaxY)) / initialOffset
        var navBarTitleAlpha: CGFloat = titleOrigin.minY-mn < navigationBarMaxY ? 1 : 0
        
        if titleOrigin.minY == 0 {
            navBarAlpha = 1
            navBarTitleAlpha = 1
        }
        
        setNavigationBarOpacity(alpha: navBarAlpha)
        
        statusBarUpdate(light: navBarTitleAlpha != 1)
        scrollReachedTouchpoint = navBarTitleAlpha == 1
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.transitionColor(fromColor: UIColor.white.withAlphaComponent(navBarAlpha), toColor: AppStyle.Base.Color.navigationTitle, progress:navBarAlpha)]
            
        self.navigationController?.navigationBar.tintColor = UIColor.transitionColor(fromColor: UIColor.white, toColor: AppStyle.Base.Color.navigationTint, progress:navBarAlpha)
        
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            guard let readController = self.getReadControllerForPeek(indexPath: indexPath, point: point) else { return nil }
            return readController
        }, actionProvider: { suggestedActions in
            let imageView = (self.tableNode?.nodeForRow(at: IndexPath(row: 0, section: 0)) as! LessonQuarterlyInfoView).coverImage.imageNode.image!
            let lesson: Lesson = (self.dataSource?.lessons[indexPath.row])!
            let share = UIAction(title: "Share".localized(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                let objectToShare = ShareItem(title: lesson.title, subtitle: lesson.dateRange, url: lesson.webURL, image: imageView)
                Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [objectToShare])
            }
            return UIMenu(title: "", children: [share])
        })
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let readController = animator.previewViewController as? ReadController else { return }
            self.presenter?.showReadScreen(readScreen: readController)
        }
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        return [UIPreviewAction(title: "Share".localized(), style: .default, handler: {
            previewAction, viewController in
                if let quarterly = self.dataSource?.quarterly {
                    self.delegate?.shareQuarterly(quarterly: quarterly)
                }
        })]
    }

    @objc func readButtonAction(sender: ASButtonNode) {
        openToday()
    }
    
    @objc func openIntroduction(sender: ASTextNode) {
        self.present(ASNavigationController(rootViewController: QuarterlyIntroductionController(quarterly: self.dataSource!.quarterly)), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollBehavior()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollBehavior()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollBehavior()
    }
}

extension LessonController: LessonControllerProtocol {
    func showLessons(quarterlyInfo: QuarterlyInfo) {
        self.dataSource = quarterlyInfo
        self.tableNode?.allowsSelection = true
        self.tableNode?.reloadData()
        
        self.title = quarterlyInfo.quarterly.title
        
        if !self.isPeeking! {
            self.insertShortcutItems(quarterlyInfo: quarterlyInfo)
        }
        
        Configuration.reloadAllWidgets()
        
        if initiateOpenToday == true {
            openToday()
            self.initiateOpenToday = false
        }
    }
}

extension LessonController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let readController = viewControllerToCommit as? ReadController else { return }
        guard let index = readController.lessonInfo?.lesson.index else { return }
        readController.previewingContext = previewingContext
        presenter?.presentReadScreen(lessonIndex: index)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableNode?.indexPathForRow(at: location) else { return nil }
        guard let cell = tableNode?.cellForRow(at: indexPath) else { return nil }
        let readController = getReadControllerForPeek(indexPath: indexPath, point: location)
        
        previewingContext.sourceRect = (tableNode?.convert(cell.frame, to: tableNode))!
        
        return readController
    }
}

extension LessonController: ReadControllerDelegate {
    func shareLesson(lesson: Lesson) {
        Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [lesson.title, lesson.webURL])
    }
}

extension LessonController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

        guard let lesson = dataSource?.lessons[indexPath.row] else {
            let cellNodeBlock: () -> ASCellNode = {

                if indexPath.section == 0 {
                    return QuarterlyEmptyView()
                }
                return LessonEmptyCellNode()
            }
            return cellNodeBlock
        }

        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.section == 0 {
                let node = LessonQuarterlyInfoView(quarterly: (self.dataSource?.quarterly)!)
                node.readButton.addTarget(self, action: #selector(self.readButtonAction(sender:)), forControlEvents: .touchUpInside)
                node.introduction.addTarget(self, action: #selector(self.openIntroduction(sender:)), forControlEvents: .touchUpInside)
                return node
            }

            return LessonView(lesson: lesson, number: "\(indexPath.row+1)")
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
