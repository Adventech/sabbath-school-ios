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

class DevotionalResourceController: CompositeScrollViewController, ASTableDataSource, DevotionalResourceDetailDelegate {
    private let devotionalInteractor = DevotionalInteractor()
    private var devotionalResource: Resource?
    private let table = ASTableNode()
    private let resourceIndex: String
    private let presenter = DevotionalPresenter()
    private var sectionStatus: Array<Bool> = []
    
    init(resourceIndex: String) {
        self.resourceIndex = resourceIndex
        super.init(node: self.table)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.table.view.separatorColor = AppStyle.Base.Color.tableSeparator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        setBackButton()
        table.view.contentInsetAdjustmentBehavior = .never

        self.devotionalInteractor.retrieveResource(index: resourceIndex) { resource in
            self.devotionalResource = resource
            self.sectionStatus = Array(repeating: self.devotionalResource?.kind == .devotional ? false : true, count: self.devotionalResource?.sections?.count ?? 0)
            self.table.reloadData()
        }
    }
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let node = { () -> ASCellNode in
            guard let resource = self.devotionalResource,
                  let sections = resource.sections else {
                return LessonEmptyCellNode()
            }
            
            if indexPath.section == 0 {
                var openButtonIndex = sections[0].documents[0].index
                var openButtonTitleText = "Read".localized()
                var openButtonSubtitleText:String? = nil
                
                if self.devotionalResource?.kind == .devotional {
                    let today = Date()
                    
                    let flatDocuments = sections.map({ (document) -> [SSPMDocument] in
                        return document.documents
                    }).flatMap({ $0 })
                    
                    for currentDocument in flatDocuments {
                        if let date = currentDocument.date {
                          if today >= date {
                              openButtonIndex = currentDocument.index
                              openButtonTitleText = currentDocument.title
                              openButtonSubtitleText = currentDocument.subtitle
                          } else { break }
                        }
                    }
                    
                    if let a = flatDocuments.first(where: {
                        $0.date?.day == Calendar.current.component(.day, from: today) &&
                        $0.date?.month == Calendar.current.component(.month, from: today) &&
                        $0.date?.year == Calendar.current.component(.year, from: today)
                    }) {
                        
                        openButtonIndex = a.index
                        openButtonTitleText = a.title
                        openButtonSubtitleText = a.subtitle
                    }
                }
                
                let header = DevotionalResourceViewHeader(
                    resource: resource,
                    openButtonIndex: openButtonIndex,
                    openButtonTitleText: openButtonTitleText,
                    openButtonSubtitleText: openButtonSubtitleText)
                
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
        
        // Making sure we adjust # of rows depending on the collapsed / expanded state of the corresponding section
        if self.devotionalResource?.kind == .devotional {
            if self.sectionStatus[section-1] {
                return (devotionalResource?.sections?[section-1].documents.count ?? 0) + 1
            } else {
                return 1
            }
        }
        
        // If non empty section (ex: section has title)
        if devotionalResource?.sections?[section-1].title != nil {
            return (devotionalResource?.sections?[section-1].documents.count ?? 0) + 1
        }
        
        // Documents inside "root" section that has no title
        return (devotionalResource?.sections?[section-1].documents.count ?? 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (devotionalResource?.sections?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let sections = self.devotionalResource!.sections else {
            return true
        }
        
        // Allowing collapsable sections (devotional content) to be clickable
        if indexPath.row == 0 && indexPath.section > 0 && sections[indexPath.section-1].title != nil {
            return self.devotionalResource?.kind == .devotional
        }

        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sections = self.devotionalResource!.sections else {
            return
        }
        
        if indexPath.section == 0 {
            return
        }
        
        // Clicking on the expand / collapse section header item
        if indexPath.row == 0 && indexPath.section > 0 && sections[indexPath.section-1].title != nil {
            if self.devotionalResource?.kind == .devotional {
                self.sectionStatus[indexPath.section-1] = !self.sectionStatus[indexPath.section-1]
                self.table.reloadSections(IndexSet(integersIn: indexPath.section...indexPath.section), with: .fade)
                
                if let sectionView = self.table.nodeForRow(at: indexPath) as? DevotionalResourceCollapsableSectionView {
                    sectionView.collapsed = !self.sectionStatus[indexPath.section-1]
                }
            }
            return
        }
        
        // Clicking on the document item
        self.didSelectResource(index: sections[indexPath.section-1].documents[indexPath.row - (sections[indexPath.section-1].title != nil ? 1 : 0)].index)
    }
    
    func didSelectResource(index: String) {
        presenter.presentDevotionalDocument(source: self, index: index)
    }
    
    override var navbarTitle: String {
        return self.devotionalResource?.title ?? ""
    }
    
    override var touchpointRect: CGRect? {
        guard let touchpoint = self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as? DevotionalResourceViewHeader else {
            return nil
        }
        return touchpoint.title.view.rectCorrespondingToWindow
    }
    
    override var parallaxEnabled: Bool {
        guard let parallaxHeaderNode = self.parallaxHeaderNode as? DevotionalResourceViewHeader else { return false }
        return parallaxHeaderNode.headerStyle == .splash
    }
    
    override var parallaxImageHeight: CGFloat? {
        guard let parallaxHeaderNode = self.parallaxHeaderNode as? DevotionalResourceViewHeader else { return 0 }
        return parallaxHeaderNode.initialSplashHeight
    }
    
    override var parallaxTargetRect: CGRect? {
        guard let parallaxHeaderNode = self.parallaxHeaderNode as? DevotionalResourceViewHeader else { return nil }
        return parallaxHeaderNode.splash.frame
    }
    
    override var parallaxHeaderNode: ASCellNode? {
        return self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as? DevotionalResourceViewHeader
    }
    
    override var parallaxHeaderCell: UITableViewCell? {
        return self.table.cellForRow(at: IndexPath(row: 0, section: 0))
    }
}
