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

class GroupedQuarterlyController: ASDKViewController<ASDisplayNode> {
    var presenter: GroupedQuarterlyPresenterProtocol?
    var dataSource = [Quarterly]()
    var groupedQuarterlies = []
    var initiateOpen: Bool?
    
    var tableNode: ASTableNode { return node as! ASTableNode }
//    var collectionNode: ASCollectionNode { return node as! ASCollectionNode }
//    let collectionViewLayout = UICollectionViewFlowLayout()
    

    override init() {
//        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        collectionViewLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        super.init(node: ASTableNode())
//        super.init(node: ASCollectionNode(collectionViewLayout: collectionViewLayout))
        tableNode.dataSource = self
//        collectionNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let settingsButton = UIBarButtonItem(image: R.image.iconNavbarSettings(), style: .done, target: self, action: #selector(logout))
//        settingsButton.accessibilityIdentifier = "openSettings"
//
//        let languagesButton = UIBarButtonItem(image: R.image.iconNavbarLanguage(), style: .done, target: self, action: #selector(showLanguages(sender:)))
//        languagesButton.accessibilityIdentifier = "openLanguage"
//
//        navigationItem.leftBarButtonItem = settingsButton
//        navigationItem.rightBarButtonItem = languagesButton
        
        presenter?.configure()
        retrieveQuarterlies()
    }
    
    func retrieveQuarterlies() {
        presenter?.presentQuarterlies()
    }
}

extension GroupedQuarterlyController: GroupedQuarterlyControllerProtocol {
    func showQuarterlies(quarterlies: [Quarterly]) {
        print("SSDEBUG", "quarterlies")
        self.dataSource = quarterlies
        Configuration.reloadAllWidgets()
    }
}

//extension GroupedQuarterlyController: ASCollectionDataSource {
//    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
//      let cellNodeBlock = { () -> ASCellNode in
//        let node = GroupItemQuarterlyController()
//        let size = CGSize(width: collectionNode.bounds.size.width, height: collectionNode.bounds.size.height/2)
//        node.style.preferredSize = size
//        return node
//      }
//
//      return cellNodeBlock
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
//}


extension GroupedQuarterlyController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
            return GroupItemQuarterlyController()
        }, didLoad: nil)

        let size = CGSize(width: tableNode.bounds.size.width, height: 135)
        node.style.preferredSize = size

        return {
            return node
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
