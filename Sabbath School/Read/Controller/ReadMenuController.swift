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
import UIKit

enum ReadMenuType {
    case originalPDF
    case readOptions
}

struct ReadMenuItem {
    var title: String
    var icon: UIImage
    var type: ReadMenuType
}

protocol ReadMenuControllerDelegate: AnyObject {
    func didSelectMenu(menuItemType: ReadMenuType)
}

class ReadMenuController: ASDKViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
    weak var delegate: ReadMenuControllerDelegate?
    var table: ASTableNode { return node as! ASTableNode }
    var items = [ReadMenuItem]()

    init(items: [ReadMenuItem]) {
        super.init(node: ASTableNode())
        table.delegate = self
        table.dataSource = self
        table.view.separatorColor = AppStyle.Base.Color.tableSeparator
        table.view.backgroundColor = AppStyle.Base.Color.background
        
        self.items = items
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        table.view.bounces = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let menuItem = items[indexPath.row]

        let cellBlock: () -> ASCellNode = {
            return ReadMenuItemView(title: menuItem.title, icon: menuItem.icon)
        }
        return cellBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss {
            self.delegate?.didSelectMenu(menuItemType: self.items[indexPath.row].type)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.table.view.separatorColor = AppStyle.Base.Color.tableSeparator
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if UIApplication.shared.applicationState != .background && self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                table.reloadData()
                self.popoverPresentationController?.backgroundColor = AppStyle.Base.Color.background
            }
        }
    }
}

extension ReadMenuController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}


class ReadMenuItemView: ASCellNode {
    let title = ASTextNode()
    let icon = ASImageNode()

    init(title: String, icon: UIImage) {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        self.isSelected = isSelected
        self.title.attributedText = AppStyle.Bible.Text.title(string: title)
        self.icon.image = icon.imageTintColor(AppStyle.Base.Color.controlActive2)
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 2,
            justifyContent: .start,
            alignItems: .start,
            children: [title]
        )

        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [vSpec, icon]
        )

        hSpec.style.alignSelf = .stretch

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15), child: hSpec)
    }
    
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? AppStyle.Lesson.Color.backgroundHighlighted : AppStyle.Lesson.Color.background }
    }
}
