//
//  MenuViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 02/12/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

struct MenuItem {
    var name: String
    var subtitle: String?
    var image: UIImage?
    var selected: Bool?
    
    static var height: CGFloat {
        return 51.5
    }
}

protocol MenuViewControllerDelegate: class {
    func menuView(menuView: MenuViewController, didSelectItemAtIndex index: Int)
}

class MenuViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
    var delegate: MenuViewControllerDelegate?
    var tableNode: ASTableNode { return node as! ASTableNode }
    var items = [MenuItem]()
    
    // MARK: Init
    
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
    
    // MARK: ASTableView data source and delegate.
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let menuItem = items[indexPath.row]
        
        let cellNodeBlock: () -> ASCellNode = {
            let cell = MenuCellNode(
                title: menuItem.name,
                subtitle: menuItem.subtitle,
                icon: menuItem.image,
                selected: menuItem.selected ?? false
            )
            return cell
        }
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // MARK: ASTableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss {
            self.delegate?.menuView(menuView: self, didSelectItemAtIndex: indexPath.row)
        }
    }
    
    // TODO: Temporary fix node resize, remove when a fix on ASDK is released.
    
    override func nodeConstrainedSize() -> ASSizeRange {
        return ASSizeRangeMakeExactSize(preferredContentSize)
    }
}
