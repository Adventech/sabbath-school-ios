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

extension UIView{
    var rectCorrespondingToWindow: CGRect{
        return self.convert(self.bounds, to: nil)
    }
}

class QuarterlyControllerV2: ASDKViewController<ASDisplayNode> {
    var presenter: QuarterlyPresenterV2Protocol?
    var groupedQuarterliesKeys = Array<QuarterlyGroup>()
    var groupedQuarterlies = [QuarterlyGroup: [Quarterly]]()
    var initiateOpen: Bool?
    
    var table: ASTableNode { return node as! ASTableNode }

    override init() {
        super.init(node: ASTableNode())
        self.table.dataSource = self
        self.table.delegate = self
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
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
        scrollBehavior()
    }
    
    private func setupNavigationBar() {
        let settingsButton = UIBarButtonItem(image: R.image.iconNavbarSettings(), style: .done, target: self, action: #selector(showSettings))
        settingsButton.accessibilityIdentifier = "openSettings"

        let languagesButton = UIBarButtonItem(image: R.image.iconNavbarLanguage(), style: .done, target: self, action: #selector(showLanguages(sender:)))
        languagesButton.accessibilityIdentifier = "openLanguage"

        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = languagesButton
        
        setNavigationBarOpacity(alpha: 0)
        self.navigationController?.navigationBar.hideBottomHairline()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(0)]
    }
    
    func retrieveQuarterlies() {
        presenter?.presentQuarterlies()
    }
    
    func scrollBehavior() {
        let mn: CGFloat = 5
        let initialOffset: CGFloat = 0
        if self.groupedQuarterlies.count <= 0 { return }
        let titleOrigin = (self.table.nodeForRow(at: IndexPath(row: 0, section: 0)) as! QuarterlyViewV2).title.view.rectCorrespondingToWindow
        guard let navigationBarMaxY =  self.navigationController?.navigationBar.rectCorrespondingToWindow.maxY else { return }
        
        var navBarAlpha: CGFloat = (initialOffset - (titleOrigin.minY + mn - navigationBarMaxY)) / initialOffset
        var navBarTitleAlpha: CGFloat = titleOrigin.maxY-mn < navigationBarMaxY ? 1 : 0
        
        if titleOrigin.minY <= 0 {
            navBarAlpha = 1
            navBarTitleAlpha = 1
        }
        
        setNavigationBarOpacity(alpha: navBarAlpha)
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(navBarTitleAlpha)]
        
    }
    
    @objc func showSettings() {
        let settings = SettingsController()

        let nc = ASNavigationController(rootViewController: settings)
        self.present(nc, animated: true)
    }
    
    @objc func showLanguages(sender: UIBarButtonItem) {
        presenter?.presentLanguageScreen()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if UIApplication.shared.applicationState != .background && self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.table.reloadData()
            }
        }
    }
}

extension QuarterlyControllerV2: QuarterlyControllerV2Protocol {
    func showQuarterlies(quarterlies: [Quarterly]) {
        groupedQuarterlies = [QuarterlyGroup: [Quarterly]]()
        var groupWeight: Int = 100
        var initialQuarterlyGroup: QuarterlyGroup?
        for quarterly in quarterlies {
            var quarterlyGroup: QuarterlyGroup
            
            if let quarterlyName = quarterly.quarterlyName {
                quarterlyGroup = QuarterlyGroup(name: quarterlyName)
            } else {
                if groupedQuarterlies.isEmpty {
                    quarterlyGroup = QuarterlyGroup(name: "Empty")
                    if initialQuarterlyGroup == nil {
                        initialQuarterlyGroup = quarterlyGroup
                    }
                } else {
                    quarterlyGroup = initialQuarterlyGroup ?? groupedQuarterlies.first!.key
                }
            }
            
            if groupedQuarterlies[quarterlyGroup] != nil {
                groupedQuarterlies[quarterlyGroup]?.append(quarterly)
            } else {
                groupWeight += 100
                quarterlyGroup.setGroupWeight(weight: groupWeight)
                groupedQuarterlies[quarterlyGroup] = [quarterly]
                if initialQuarterlyGroup == nil {
                    initialQuarterlyGroup = quarterlyGroup
                }
            }
        }
        
        groupedQuarterliesKeys = Array(groupedQuarterlies.keys).sorted(by: { $0.weight < $1.weight })
        self.table.reloadData()
        Configuration.reloadAllWidgets()
    }
}

extension QuarterlyControllerV2: ASTableDelegate {
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

extension QuarterlyControllerV2: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.section == 0 {
            let cellNodeBlock: () -> ASCellNode = {
                return QuarterlyViewV2(title: "Sabbath School".localized())
            }
            return cellNodeBlock
        }
        
        if groupedQuarterlies.isEmpty {
            let cellNodeBlock: () -> ASCellNode = {
                return ASCellNode()
            }
            return cellNodeBlock
        }
        
        if groupedQuarterliesKeys.count == 1 {
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

            let size = CGSize(width: self.table.bounds.size.width, height: 358)
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
        return groupedQuarterlies.isEmpty ? 3 : (groupedQuarterliesKeys.count == 1 ? (groupedQuarterlies[groupedQuarterliesKeys[0]]?.count)! : groupedQuarterliesKeys.count)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
