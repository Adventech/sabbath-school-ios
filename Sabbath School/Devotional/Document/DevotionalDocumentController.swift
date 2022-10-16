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

class DevotionalDocumentController: ASDKViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, BlockActionsDelegate {
    private let devotionalInteractor = DevotionalInteractor()
    private var table = ASTableNode()
    private var blocks: [Block] = []
    private var document: SSPMDocument?
    private let index: String
    private let devotionalPresenter = DevotionalPresenter()
    
    private var scrollReachedTouchpoint: Bool = false
    private var everScrolled: Bool = false

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
        setupNavigationbar()
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
        setupNavigationbar()
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
    
    func setupNavigationbar() {
        self.navigationController?.navigationBar.hideBottomHairline()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(0)]
        self.navigationController?.navigationBar.tintColor = AppStyle.Base.Color.navigationTint
        setBackButton()
    }
    
    func scrollBehavior() {
        let mn: CGFloat = 0
        let initialOffset: CGFloat = 50
        
        if self.document == nil { return }
        
        if let document = self.document {
            if document.blocks?.count ?? 0 <= 0 { return }
        }
        
        let titleOrigin = (self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as! DocumentHeadNode).titleNode.view.rectCorrespondingToWindow
        
        guard let navigationBarMaxY =  self.navigationController?.navigationBar.rectCorrespondingToWindow.maxY else { return }

        var navBarAlpha: CGFloat = (initialOffset - (titleOrigin.minY + mn - navigationBarMaxY)) / initialOffset
        var navBarTitleAlpha: CGFloat = titleOrigin.minY-mn < navigationBarMaxY ? 1 : 0
        
        if titleOrigin.minY == 0 {
            navBarAlpha = everScrolled ? 1 : 0
            navBarTitleAlpha = everScrolled ? 1 : 0
        }
        
        setNavigationBarOpacity(alpha: navBarAlpha)
        
        title = navBarAlpha < 1 ? "" : self.document?.title
        
        scrollReachedTouchpoint = navBarTitleAlpha == 1
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.transitionColor(fromColor: UIColor.white.withAlphaComponent(navBarAlpha), toColor: AppStyle.Base.Color.navigationTitle, progress:navBarAlpha)]
            
        self.navigationController?.navigationBar.tintColor = AppStyle.Base.Color.navigationTint
    }
    
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
    
    func didClickBible(bibleVerses: [BibleVerses], verse: String) {
        let bibleScreen = BibleWireFrame.createBibleModule(bibleVerses: bibleVerses, verse: verse)
        let navigation = ASNavigationController(rootViewController: bibleScreen)
        
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
