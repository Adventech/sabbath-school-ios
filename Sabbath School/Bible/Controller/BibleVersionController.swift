//
//  BibleVersionController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

struct MenuItem {
    var name: String
    var subtitle: String?
    var image: UIImage?
    var selected: Bool?
    
    static var height: CGFloat {
        return 51.5
    }
}

protocol BibleVersionControllerDelegate: class {
    func didSelectVersion(versionName: String)
}

class BibleVersionController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
    var delegate: BibleVersionControllerDelegate?
    var tableNode: ASTableNode { return node as! ASTableNode }
    var items = [MenuItem]()
    
    init(withItems items: [MenuItem]) {
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorColor = UIColor.baseSeparator
        tableNode.view.isScrollEnabled = false
        self.items = items
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let menuItem = items[indexPath.row]
        
        let cellNodeBlock: () -> ASCellNode = {
            return BibleVersionView(title: menuItem.name, isSelected: menuItem.selected ?? false)
        }
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss {
            self.delegate?.didSelectVersion(versionName: self.items[indexPath.row].name)
        }
    }
}
