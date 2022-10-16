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
import UIKit

class DevotionalResourceController: ASDKViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, DevotionalResourceDetailDelegate {
    private let devotionalInteractor = DevotionalInteractor()
    private var devotionalResource: Resource?
    private let table = ASTableNode()
    private let resourceIndex: String
    private var scrollReachedTouchpoint: Bool = false
    private var everScrolled: Bool = false
    private let presenter = DevotionalPresenter()
    private var status: Array<Bool> = []
    
    init(resourceIndex: String) {
        self.resourceIndex = resourceIndex
        super.init(node: self.table)
        table.dataSource = self
        table.delegate = self
        view.backgroundColor = .white | .black
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return scrollReachedTouchpoint ? .default : .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.table.view.separatorColor = AppStyle.Base.Color.tableSeparator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    func statusBarUpdate(light: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    func setupNavigationbar() {
        setNavigationBarOpacity(alpha: 0)
        self.navigationController?.navigationBar.hideBottomHairline()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(0)]
        self.navigationController?.navigationBar.barTintColor = nil
        setBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
        setupNavigationbar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        table.view.contentInsetAdjustmentBehavior = .never
        setupNavigationbar()
        
        self.devotionalInteractor.retrieveResource(index: resourceIndex) { resource in
            self.devotionalResource = resource
            self.status = Array(repeating: self.devotionalResource?.kind == .devotional ? false : true, count: self.devotionalResource?.sections?.count ?? 0)
            self.table.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationbar()
        scrollBehavior()
    }
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let node = { () -> ASCellNode in
            guard let resource = self.devotionalResource,
                  let sections = resource.sections else {
                return LessonEmptyCellNode()
            }
            
            if indexPath.section == 0 {
                let openButtonIndex = sections[0].documents[0].index
                let header = DevotionalResourceViewHeader(resource: resource, openButtonIndex: openButtonIndex, openButtonTitleText: "Read")
                header.delegate = self
                return header
            } else {
                
                if sections[indexPath.section-1].title != nil && indexPath.row == 0 {
                    if self.devotionalResource?.kind == .devotional {
                        return DevotionalResourceCollapsableSectionView(section: sections[indexPath.section-1])
                    }
                    return DevotionalResourceSectionView(section: sections[indexPath.section-1])
                }
                
                let document = sections[indexPath.section-1].documents[indexPath.row - (sections[indexPath.section-1].title != nil ? 1 : 0)]
                return DevotionalResourceDocumentView(document: document)
            }
        }
        return node
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        
        if self.devotionalResource?.kind == .devotional {
            if self.status[section-1] {
                return (devotionalResource?.sections?[section-1].documents.count ?? 0) + 1
            } else {
                return 1
            }
        }
        
        if devotionalResource?.sections?[section-1].title != nil {
            return (devotionalResource?.sections?[section-1].documents.count ?? 0) + 1
        }
        
        return (devotionalResource?.sections?[section-1].documents.count ?? 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (devotionalResource?.sections?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let sections = self.devotionalResource!.sections else {
            return true
        }
        
        if indexPath.row == 0 && indexPath.section > 1 && sections[indexPath.section-1].title != nil {
            return self.devotionalResource?.kind == .devotional ? true : false
        }

        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sections = self.devotionalResource!.sections else {
            return
        }
        
        if indexPath.row == 0 && indexPath.section == 0 {
            return
        }
        
        if indexPath.row == 0 && indexPath.section > 0 && self.devotionalResource?.kind == .devotional {
            self.status[indexPath.section-1] = !self.status[indexPath.section-1]
            self.table.reloadSections(IndexSet(integersIn: indexPath.section...indexPath.section), with: .fade)
            
            if let sectionView = self.table.nodeForRow(at: indexPath) as? DevotionalResourceCollapsableSectionView {
                sectionView.collapsed = !self.status[indexPath.section-1]
            }
            
            return
        }
        
        self.didSelectResource(index: sections[indexPath.section-1].documents[indexPath.row - (sections[indexPath.section-1].title != nil ? 1 : 0)].index)
    }
    
    func didSelectResource(index: String) {
        presenter.presentDevotionalDocument(source: self, index: index)
    }
    
    func scrollBehavior() {
        let mn: CGFloat = 0
        let initialOffset: CGFloat = 50
        
        if self.devotionalResource == nil { return }
        
        if let devotionalResource = self.devotionalResource {
            if devotionalResource.sections?.count ?? 0 <= 0 { return }
        }
        
        let titleOrigin = (self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as! DevotionalResourceViewHeader).title.view.rectCorrespondingToWindow
        
        guard let navigationBarMaxY =  self.navigationController?.navigationBar.rectCorrespondingToWindow.maxY else { return }

        var navBarAlpha: CGFloat = (initialOffset - (titleOrigin.minY + mn - navigationBarMaxY)) / initialOffset
        var navBarTitleAlpha: CGFloat = titleOrigin.minY-mn < navigationBarMaxY ? 1 : 0
        
        if titleOrigin.minY == 0 {
            navBarAlpha = everScrolled ? 1 : 0
            navBarTitleAlpha = everScrolled ? 1 : 0
        }
        
        setNavigationBarOpacity(alpha: navBarAlpha)
        
        title = navBarAlpha < 1 ? "" : self.devotionalResource?.title
        
        statusBarUpdate(light: navBarTitleAlpha != 1)
        scrollReachedTouchpoint = navBarTitleAlpha == 1
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.transitionColor(fromColor: UIColor.white.withAlphaComponent(navBarAlpha), toColor: AppStyle.Base.Color.navigationTitle, progress:navBarAlpha)]
            
        self.navigationController?.navigationBar.tintColor = UIColor.transitionColor(fromColor: UIColor.white, toColor: AppStyle.Base.Color.navigationTint, progress:navBarAlpha)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        everScrolled = true
        scrollBehavior()
        parallax(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        everScrolled = true
        scrollBehavior()
        parallax(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        everScrolled = true
        scrollBehavior()
        parallax(scrollView)
    }
    
    func parallax(_ scrollView: UIScrollView) {
        if let coverHeader = self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as? DevotionalResourceViewHeader {
            if coverHeader.headerStyle != .splash { return }
            let scrollOffset = scrollView.contentOffset.y
            
            if scrollOffset >= 0 {
                coverHeader.splash.frame.origin.y = scrollOffset / 2
            } else {
                if let cellHeader = self.table.cellForRow(at: IndexPath(row: 0, section: 0)) {
                    cellHeader.frame.origin.y = scrollOffset
                    cellHeader.frame.size.height = coverHeader.initialSplashHeight + (-scrollOffset)
                    coverHeader.frame.size.height = coverHeader.initialSplashHeight + (-scrollOffset)
                }
            }
        }
    }
}
