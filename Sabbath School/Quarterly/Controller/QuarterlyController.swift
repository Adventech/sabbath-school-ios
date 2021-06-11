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

import AsyncDisplayKit
import FirebaseAuth
import UIKit
import LinkPresentation

class QuarterlyController: TableController {
    var presenter: QuarterlyPresenterProtocol?
    var dataSource = [Quarterly]()
    var initiateOpen: Bool?
        
    override init() {
        super.init()

        tableNode?.dataSource = self
        tableNode?.allowsSelection = false
        tableNode?.backgroundColor = AppStyle.Base.Color.background

        title = "Sabbath School".localized().uppercased()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let settingsButton = UIBarButtonItem(image: R.image.iconNavbarSettings(), style: .done, target: self, action: #selector(logout))
        settingsButton.accessibilityIdentifier = "openSettings"

        let languagesButton = UIBarButtonItem(image: R.image.iconNavbarLanguage(), style: .done, target: self, action: #selector(showLanguages(sender:)))
        languagesButton.accessibilityIdentifier = "openLanguage"

        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = languagesButton
        
        presenter?.configure()
        retrieveQuarterlies()
        
        if #available(iOS 13, *) {} else {
            if self.traitCollection.forceTouchCapability == .available, let view = tableNode?.view {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
        
        if !Preferences.gcPopupStatus() {
            UserDefaults.standard.set(true, forKey: Constants.DefaultKey.gcPopup)
            showGCPopup()
        } else if initiateOpen ?? false {
            let lastQuarterlyIndex = Preferences.currentQuarterly()
            let languageCode = lastQuarterlyIndex.components(separatedBy: "-")
            if let code = languageCode.first, Preferences.currentLanguage().code == code {
                presenter?.presentLessonScreen(quarterlyIndex: lastQuarterlyIndex, initiateOpenToday: false)
            }
        }
    }
    
    func retrieveQuarterlies() {
        self.dataSource = [Quarterly]()
        self.tableNode?.allowsSelection = false
        self.tableNode?.reloadData()
        presenter?.presentQuarterlies()
    }

    func showGCPopup() {
        presenter?.presentGCScreen()
    }
    
    func getLessonControllerForPeek(indexPath: IndexPath, point: CGPoint) -> LessonController? {
        let quarterlyIndex = self.dataSource[indexPath.row].index
        let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: false)
        lessonController.isPeeking = true
        lessonController.delegate = self
        return lessonController
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            guard let lessonController = self.getLessonControllerForPeek(indexPath: indexPath, point: point) else { return nil }
            return lessonController
        }, actionProvider: { suggestedActions in
            let imageView: UIImage
            if indexPath.row == 0 {
                imageView = (self.tableNode?.nodeForRow(at: indexPath) as! QuarterlyFeaturedView).coverImage.imageNode.image!
            } else {
                imageView = (self.tableNode?.nodeForRow(at: indexPath) as! QuarterlyView).coverImage.imageNode.image!
            }
            let quarterly: Quarterly = self.dataSource[indexPath.row]
            let share = UIAction(title: "Share".localized(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                let objectToShare = ShareItem(title: quarterly.title, subtitle: quarterly.humanDate, url: quarterly.webURL, image: imageView)
                Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [objectToShare])
            }
            return UIMenu(title: "", children: [share])
        })
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let lessonController = animator.previewViewController as? LessonController else { return }
            self.presenter?.showLessonScreen(lessonScreen: lessonController)
        }
    }
    
    @objc func openButtonAction(sender: ASButtonNode) {
        presenter?.presentLessonScreen(quarterlyIndex: dataSource[0].index, initiateOpenToday: false)
    }
    
    @objc func showLanguages(sender: UIBarButtonItem) {
        presenter?.presentLanguageScreen()
    }

    @objc func logout() {
        let settings = SettingsController()

        let nc = ASNavigationController(rootViewController: settings)
        self.present(nc, animated: true)
    }
}

extension QuarterlyController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableNode?.indexPathForRow(at: location) else { return nil }
        guard let lessonController = self.getLessonControllerForPeek(indexPath: indexPath, point: location) else { return nil }
        guard let cell = tableNode?.cellForRow(at: indexPath) else { return nil }
        previewingContext.sourceRect = (tableNode?.convert(cell.frame, to: tableNode))!
        
        return lessonController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let lessonController = viewControllerToCommit as? LessonController else { return }
        presenter?.showLessonScreen(lessonScreen: lessonController)
    }
}

extension QuarterlyController: LessonControllerDelegate {
    func shareQuarterly(quarterly: Quarterly) {
        Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [quarterly.title, quarterly.webURL])
    }
}

extension QuarterlyController: QuarterlyControllerProtocol {
    func showQuarterlies(quarterlies: [Quarterly]) {
        self.dataSource = quarterlies

        if let colorHex = self.dataSource.first?.colorPrimary {
            self.colorPrimary = UIColor(hex: colorHex)
        }

        self.colorize()
        self.tableNode?.allowsSelection = true
        self.tableNode?.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.dataSource.isEmpty {
            let quarterly = dataSource[indexPath.row]

            if let colorHex = quarterly.colorPrimary {
                setTranslucentNavigation(true, color: UIColor(hex: colorHex), tintColor: .white, titleColor: .white)
            }

            presenter?.presentLessonScreen(quarterlyIndex: quarterly.index, initiateOpenToday: false)
        }
    }
}

extension QuarterlyController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            if self.dataSource.isEmpty {
                return QuarterlyEmptyView()
            }

            let quarterly = self.dataSource[indexPath.row]

            if indexPath.row == 0 {
                let node = QuarterlyFeaturedView(quarterly: quarterly)
                node.openButton.addTarget(self, action: #selector(self.openButtonAction(sender:)), forControlEvents: .touchUpInside)
                return node
            }

            return QuarterlyView(quarterly: quarterly)
        }

        return cellNodeBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty {
            return 6
        }
        return dataSource.count
    }
}
