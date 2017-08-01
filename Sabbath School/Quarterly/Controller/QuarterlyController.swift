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
import FirebaseAuth
import UIKit

class QuarterlyController: TableController {
    var presenter: QuarterlyPresenterProtocol?
    let animator = PopupTransitionAnimator()

    var dataSource = [Quarterly]()

    override init() {
        super.init()

        tableNode.dataSource = self
        tableNode.allowsSelection = false

        title = "Sabbath School".localized().uppercased()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let lastQuarterlyIndex = currentQuarterly()
        if !lastQuarterlyIndex.isEmpty {
            presenter?.presentLessonScreen(quarterlyIndex: lastQuarterlyIndex)
        }

        let settingsButton = UIBarButtonItem(image: R.image.iconNavbarSettings(), style: .done, target: self, action: #selector(logoutAction))
        settingsButton.accessibilityIdentifier = "openSettings"

        let rightButton = UIBarButtonItem(image: R.image.iconNavbarLanguage(), style: .done, target: self, action: #selector(rightAction(sender:)))
        rightButton.accessibilityIdentifier = "openLanguage"

        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = rightButton
        presenter?.configure()
        retrieveQuarterlies()
    }

    func retrieveQuarterlies() {
        self.dataSource = [Quarterly]()
        self.tableNode.allowsSelection = false
        self.tableNode.reloadData()
        presenter?.presentQuarterlies()
    }

    func rightAction(sender: UIBarButtonItem) {
        let buttonView = sender.value(forKey: "view") as! UIView
        let size = CGSize(width: node.frame.width, height: round(node.frame.height*0.8))

        animator.style = .arrow
        animator.fromView = buttonView
        animator.arrowColor = .tintColor

        presenter?.presentLanguageScreen(size: size, transitioningDelegate: animator)
    }

    func openButtonAction(sender: OpenButton) {
        presenter?.presentLessonScreen(quarterlyIndex: dataSource[0].index)
    }

    func logoutAction() {
        let settings = SettingsController()

        let nc = ASNavigationController(rootViewController: settings)
        self.present(nc, animated: true)
    }
}

extension QuarterlyController: QuarterlyControllerProtocol {
    func showQuarterlies(quarterlies: [Quarterly]) {
        self.dataSource = quarterlies

        if let colorHex = self.dataSource.first?.colorPrimary {
            self.colorPrimary = UIColor(hex: colorHex)
        }

        self.colorize()
        self.tableNode.allowsSelection = true
        self.tableNode.reloadData()
        self.correctHairline()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.dataSource.isEmpty {
            let quarterly = dataSource[indexPath.row]

            if let colorHex = quarterly.colorPrimary {
                setTranslucentNavigation(true, color: UIColor(hex: colorHex), tintColor: .white, titleColor: .white)
            }

            presenter?.presentLessonScreen(quarterlyIndex: quarterly.index)
        }
    }
}

extension QuarterlyController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            if self.dataSource.isEmpty {
                return QuarterlyEmptyCell()
            }

            let quarterly = self.dataSource[indexPath.row]

            if indexPath.row == 0 {
                let node = QuarterlyFeaturedCellNode(quarterly: quarterly)
                node.openButton.addTarget(self, action: #selector(self.openButtonAction(sender:)), forControlEvents: .touchUpInside)
                return node
            }

            return QuarterlyCellNode(quarterly: quarterly)
        }

        return cellNodeBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty {
            return 6
        }
        return dataSource.count
    }
}
