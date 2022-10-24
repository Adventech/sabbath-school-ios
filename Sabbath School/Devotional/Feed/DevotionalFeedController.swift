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

enum DevotionalType {
    case study
    case pm
    
    func getTitle() -> String {
        switch self {
        case .study:
            return "Devotional".localized()
        case .pm:
            return "Personal Ministries".localized()
        }
    }
}

class DevotionalFeedController: ASDKViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, DevotionalGroupDelegate {
    private let devotionalInteractor = DevotionalInteractor()
    private var devotionalResources: [ResourceFeed] = []
    private let table = ASTableNode()
    private let presenter = DevotionalPresenter()
    private let devotionalType: DevotionalType
    
    init(devotionalType: DevotionalType) {
        self.devotionalType = devotionalType
        super.init(node: self.table)
        table.dataSource = self
        table.delegate = self
        
        view.backgroundColor = .white | .black
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        setNavigationBarOpacity(alpha: 1)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = devotionalType.getTitle()
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: AppStyle.Base.Color.navigationTitle,
            .font: R.font.latoBlack(size: 36)!
        ]
        
        table.view.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.devotionalInteractor.retrieveFeed(devotionalType: self.devotionalType, language: "en") { resourceFeed in
            self.devotionalResources = resourceFeed
        }
    }
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        switch devotionalResources[indexPath.row] {
        case .resourceGroup(let resourceGroup):
            let node = { () -> ASCellNode in
                switch resourceGroup.view {
                case .list:
                    let devotionalGroup = DevotionalFeedGroupListView(groupIndex: indexPath.row, resourceGroup: resourceGroup)
                    devotionalGroup.delegate = self
                    return devotionalGroup
                case .tileSmall:
                    let devotionalGroup = DevotionalFeedGroupSmallTileView(groupIndex: indexPath.row, resourceGroup: resourceGroup)
                    devotionalGroup.delegate = self
                    return devotionalGroup
                case .tile:
                    let devotionalGroup = DevotionalFeedGroupTileView(groupIndex: indexPath.row, resourceGroup: resourceGroup)
                    devotionalGroup.delegate = self
                    return devotionalGroup
                default:
                    let devotionalGroup = DevotionalFeedGroupBookView(groupIndex: indexPath.row, resourceGroup: resourceGroup)
                    devotionalGroup.delegate = self
                    return devotionalGroup
                }
            }

            return node
        case .resource(let resource):
            let node = { () -> ASCellNode in
                switch resource.view {
                case .book:
                    return DevotionalFeedBookView(resource: resource, inline: true)
                default:
                    return DevotionalFeedTileView(resource: resource, inline: true)
                }
                
            }
            return node
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devotionalResources.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch devotionalResources[indexPath.row] {
        case .resource(let resource):
            presenter.presentDevotionalDetail(source: self, index: resource.index)
        default:
            return
        }
        
    }
    
    func didSelectResource(groupIndex: Int, resourceIndex: Int) {
        switch devotionalResources[groupIndex] {
        case .resourceGroup(let resourceGroup):
            presenter.presentDevotionalDetail(source: self, index: resourceGroup.resources[resourceIndex].index)
        default:
            return
        }
    }
}
