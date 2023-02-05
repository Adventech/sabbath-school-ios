/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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
import SafariServices
import SwiftEntryKit

class DevotionalDocumentController: CompositeScrollViewController, ASTableDataSource, BlockActionsDelegate, TabBarLessViewController {
    private let devotionalInteractor = DevotionalInteractor()
    private var table = ASTableNode()
    private var blocks: [Block] = []
    private var document: SSPMDocument?
    private let index: String
    private let devotionalPresenter = DevotionalPresenter()

    init(index: String) {
        self.index = index
        super.init(node: table)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = AppStyle.Base.Color.background
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.view.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.table.allowsSelection = false
        self.table.view.contentInsetAdjustmentBehavior = .never
        
        self.devotionalInteractor.retrieveDocument(index: index) { resourceDocument in
            self.document = resourceDocument
            self.title = resourceDocument.title
            self.table.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.table.contentInset.bottom = 0
        } else {
            var contentInset: UIEdgeInsets = self.table.contentInset
            contentInset.bottom = keyboardViewEndFrame.size.height
            contentInset.bottom = contentInset.bottom - view.safeAreaInsets.bottom
            self.table.contentInset = contentInset
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            if (indexPath.section == 0) {
                return DocumentHeadNode(title: self.document?.title ?? "", subtitle: self.document?.subtitle)
            }
            return DevotionalDocumentView(blocks: self.document?.blocks ?? [], vc: self)
        }

        return cellNodeBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override var tintColors: (fromColor: UIColor, toColor: UIColor) {
        return (AppStyle.Base.Color.navigationTint, AppStyle.Base.Color.navigationTint)
    }
    
    override var navbarTitle: String {
        return self.document?.title ?? ""
    }
    
    override var touchpointRect: CGRect? {
        guard let touchpoint = self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as? DocumentHeadNode else {
            return nil
        }
        return touchpoint.titleNode.view.rectCorrespondingToWindow
    }
    
    override var parallaxEnabled: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func didClickBible(bibleVerses: [BibleVerses], verse: String) {
        let bibleScreen = BibleWireFrame.createBibleModule(bibleVerses: bibleVerses, verse: verse)
        let navigation = SSNavigationController(rootViewController: bibleScreen)
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        SwiftEntryKit.display(entry: navigation, using: Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: Preferences.currentTheme().backgroundColor))
    }
    
    func didClickURL(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.view.tintColor = AppStyle.Base.Color.tint
        safariVC.modalPresentationStyle = .currentContext
        present(safariVC, animated: true, completion: nil)
    }
    
    func didClickReference(scope: Block.ReferenceScope, index: String) {
        switch scope {
        case .document:
            self.devotionalPresenter.presentDevotionalDocument(source: self, index: index)
        case .resource:
            self.devotionalPresenter.presentDevotionalDetail(source: self, index: index)
        }
    }
}
