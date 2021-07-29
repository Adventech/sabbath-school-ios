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

class TableController: ThemeController {
    weak var tableNode: ASTableNode? { return node as? ASTableNode }

    override init() {
        super.init(node: ASTableNode())

        tableNode?.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableNode?.allowsSelection = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // correctHairline()
    }

    override func viewWillAppear(_ animated: Bool) {
        // navigationController?.navigationBar.hideBottomHairline()
        super.viewWillAppear(animated)

        if let selected = tableNode?.indexPathForSelectedRow {
            tableNode?.view.deselectRow(at: selected, animated: true)
        }

        // correctHairline()
        // colorize()
    }

    func correctHairline() {
        return
        guard
            let navigationBarHeight = self.navigationController?.navigationBar.frame.height,
            let tableNode = self.tableNode
        else {
            return
        }

        if tableNode.contentOffset.y >= -navigationBarHeight {
            navigationController?.navigationBar.showBottomHairline()
        } else {
            navigationController?.navigationBar.hideBottomHairline()
        }

        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableNode?.view.separatorColor = AppStyle.Base.Color.tableSeparator
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if UIApplication.shared.applicationState != .background && self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                tableNode?.reloadData()
            }
        }
    }
}

extension TableController: ASTableDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Implement within actual controller
    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // self.correctHairline()
//    }
}
