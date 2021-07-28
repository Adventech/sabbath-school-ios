/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

import AsyncDisplayKit

enum QuarterlyViewPreference {
    case grouped
    case ungrouped
}

class QuarterlyControllerCommon: ASDKViewController<ASDisplayNode> {
    let selectedQuarterlyGroup: QuarterlyGroup?
    
    var presenter: QuarterlyPresenterV2Protocol?
    var groupedQuarterliesKeys = Array<QuarterlyGroup>()
    var groupedQuarterlies = [QuarterlyGroup: [Quarterly]]()
    var initiateOpen: Bool?
    
    var quarterlyViewPreference: QuarterlyViewPreference = .grouped
    var everScrolled: Bool = false
    var table: ASTableNode { return node as! ASTableNode }
    
    private var currentTransitionCoordinator: UIViewControllerTransitionCoordinator?

    override init() {
        selectedQuarterlyGroup = nil
        super.init(node: ASTableNode())
        self.setupTable()
    }
    
    init(selectedQuarterlyGroup: QuarterlyGroup?) {
        self.selectedQuarterlyGroup = selectedQuarterlyGroup
        super.init(node: ASTableNode())
        self.setupTable()
    }
    
    func setupTable() {
        self.table.dataSource = self
        self.table.delegate = self
        self.table.backgroundColor = AppStyle.Base.Color.background
        title = "Sabbath School".localized()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.allowsSelection = false
        self.table.view.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        presenter?.configure()
        retrieveQuarterlies()
        
        if #available(iOS 13, *) {} else {
            if self.traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: table.view)
            }
        }
        self.navigationController?.interactivePopGestureRecognizer?.addTarget(self, action:#selector(self.handlePopGesture))
    }
    
    @objc func handlePopGesture(gesture: UIGestureRecognizer) -> Void {
        switch gesture.state {
        case .began, .changed:
            if let ct = navigationController?.transitionCoordinator {
                currentTransitionCoordinator = ct
            }
        case .cancelled, .ended:
            currentTransitionCoordinator = nil
        case .possible, .failed:
            break
        }

        if let currentTransitionCoordinator = currentTransitionCoordinator {
            if self.navigationController?.navigationBar.subviews.first?.alpha == 0 {
                
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollBehavior()
    }
    
    func retrieveQuarterlies() {
        presenter?.presentQuarterlies()
    }
    
    func scrollBehavior() {
        
        let mn: CGFloat = 5
        let initialOffset: CGFloat = 20
        if self.groupedQuarterlies.count <= 0 { return }
        let titleOrigin = (self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as! QuarterlyHeaderView).title.view.rectCorrespondingToWindow
        
        guard let navigationBarMaxY =  self.navigationController?.navigationBar.rectCorrespondingToWindow.maxY else { return }
        
        var navBarAlpha: CGFloat = (initialOffset - (titleOrigin.minY + mn - navigationBarMaxY)) / initialOffset
        var navBarTitleAlpha: CGFloat = titleOrigin.maxY-mn < navigationBarMaxY ? 1 : 0

        if titleOrigin.minY == 0 && titleOrigin.maxY == 0 {
            navBarAlpha = 0
            navBarTitleAlpha = 0
        }
        
        setNavigationBarOpacity(alpha: navBarAlpha)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(navBarTitleAlpha)]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if UIApplication.shared.applicationState != .background && self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.table.reloadData()
            }
        }
    }
    
    func getLessonControllerForPeek(indexPath: IndexPath, point: CGPoint) -> LessonController? {
        if quarterlyViewPreference == .grouped { return nil }
        let quarterlyIndex = groupedQuarterlies[groupedQuarterliesKeys[0]]![indexPath.row].index
        let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: false)
        lessonController.isPeeking = true
        lessonController.delegate = self
        return lessonController
    }
}

extension QuarterlyControllerCommon: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if quarterlyViewPreference == .grouped { return nil }
        guard let indexPath = self.table.indexPathForRow(at: location) else { return nil }
        guard let lessonController = self.getLessonControllerForPeek(indexPath: indexPath, point: location) else { return nil }
        guard let cell = self.table.cellForRow(at: indexPath) else { return nil }
        previewingContext.sourceRect = self.table.convert(cell.frame, to: self.table)
        
        return lessonController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if quarterlyViewPreference == .grouped { return }
        guard let lessonController = viewControllerToCommit as? LessonController else { return }
        presenter?.showLessonScreen(lessonScreen: lessonController)
    }
}

extension QuarterlyControllerCommon: QuarterlyControllerV2Protocol {
    func showQuarterlies(quarterlies: [Quarterly]) {
        groupedQuarterlies = [QuarterlyGroup: [Quarterly]]()
        var initialQuarterlyGroup: QuarterlyGroup?
        for quarterly in quarterlies {
            if let selectedQuarterlyGroup = selectedQuarterlyGroup, let quarterlyGroup = quarterly.quarterlyGroup {
                if (quarterlyGroup != selectedQuarterlyGroup) { continue }
                if groupedQuarterlies[selectedQuarterlyGroup] != nil {
                    groupedQuarterlies[selectedQuarterlyGroup]?.append(quarterly)
                } else {
                    groupedQuarterlies[selectedQuarterlyGroup] = [quarterly]
                }
            } else {
                var quarterlyGroup: QuarterlyGroup? = quarterly.quarterlyGroup
                
                if quarterlyGroup == nil {
                    if groupedQuarterlies.isEmpty {
                        quarterlyGroup = QuarterlyGroup(name: "Empty")
                        if initialQuarterlyGroup == nil {
                            initialQuarterlyGroup = quarterlyGroup
                        }
                    } else {
                        quarterlyGroup = initialQuarterlyGroup ?? groupedQuarterlies.first!.key
                    }
                }
                
                if groupedQuarterlies[quarterlyGroup!] != nil {
                    groupedQuarterlies[quarterlyGroup!]?.append(quarterly)
                } else {
                    groupedQuarterlies[quarterlyGroup!] = [quarterly]
                    if initialQuarterlyGroup == nil {
                        initialQuarterlyGroup = quarterlyGroup!
                    }
                }
            }
        }
        groupedQuarterliesKeys = Array(groupedQuarterlies.keys).sorted(by: { $0.order < $1.order })
        quarterlyViewPreference = groupedQuarterliesKeys.count == 1 ? .ungrouped : .grouped
        self.table.allowsSelection = quarterlyViewPreference == .ungrouped
        self.table.reloadData()
        Configuration.reloadAllWidgets()
    }
}

extension QuarterlyControllerCommon: ASTableDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        everScrolled = true
        scrollBehavior()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        everScrolled = true
        scrollBehavior()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        everScrolled = true
        scrollBehavior()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if quarterlyViewPreference == .grouped { return nil }
        if indexPath.section != 1 { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            guard let lessonController = self.getLessonControllerForPeek(indexPath: indexPath, point: point) else { return nil }
            return lessonController
        }, actionProvider: { suggestedActions in
            let imageView: UIImage
            imageView = (self.table.nodeForRow(at: indexPath) as! QuarterlyView).coverImage.imageNode.image!
            let quarterly: Quarterly = self.groupedQuarterlies[self.groupedQuarterliesKeys[0]]![indexPath.row]
            let share = UIAction(title: "Share".localized(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                let objectToShare = ShareItem(title: quarterly.title, subtitle: quarterly.humanDate, url: quarterly.webURL, image: imageView)
                Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [objectToShare])
            }
            return UIMenu(title: "", children: [share])
        })
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if quarterlyViewPreference == .grouped { return }
        animator.addCompletion {
            guard let lessonController = animator.previewViewController as? LessonController else { return }
            self.presenter?.showLessonScreen(lessonScreen: lessonController)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1 { return }
        if !self.groupedQuarterlies.isEmpty && quarterlyViewPreference == .ungrouped {
            let quarterly = groupedQuarterlies[groupedQuarterliesKeys[0]]![indexPath.row]
            presenter?.presentLessonScreen(quarterlyIndex: quarterly.index, initiateOpenToday: false)
        }
    }
}

extension QuarterlyControllerCommon: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.section == 0 {
            let cellNodeBlock: () -> ASCellNode = {
                return QuarterlyHeaderView(title: self.selectedQuarterlyGroup?.name ?? "Sabbath School".localized())
            }
            return cellNodeBlock
        }
        
        if groupedQuarterlies.isEmpty {
            let cellNodeBlock: () -> ASCellNode = {
                return ASCellNode()
            }
            return cellNodeBlock
        }
        
        if quarterlyViewPreference == .ungrouped {
            let cellNodeBlock: () -> ASCellNode = {
                let key = self.groupedQuarterliesKeys[0]
                return QuarterlyView(quarterly: self.groupedQuarterlies[key]![indexPath.row])
            }
            return cellNodeBlock
        } else {
            let key = self.groupedQuarterliesKeys[indexPath.row]
            let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
                return GroupedQuarterlyController(presenter: self.presenter, quarterlyGroup: key, quarterlies: self.groupedQuarterlies[key] ?? [], isLast: indexPath.row == self.groupedQuarterliesKeys.count-1)
            }, didLoad: nil)
            
            node.layoutIfNeeded()
            
            let size = CGSize(width: self.table.bounds.size.width, height: AppStyle.Quarterly.Size.coverImage().height + 140)
            node.style.preferredSize = size
            return {
                return node
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return groupedQuarterlies.isEmpty ? 3 : (quarterlyViewPreference == .ungrouped ? (groupedQuarterlies[groupedQuarterliesKeys[0]]?.count)! : groupedQuarterliesKeys.count)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension QuarterlyControllerCommon: LessonControllerDelegate {
    func shareQuarterly(quarterly: Quarterly) {
        Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [quarterly.title, quarterly.webURL])
    }
}
