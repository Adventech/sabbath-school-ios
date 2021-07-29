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
import SwiftEntryKit

class BibleController: ASDKViewController<ASDisplayNode> {
    var presenter: BiblePresenterProtocol?
    var bibleView = BibleView()
    var versionButton: UIButton!

    var read: Read?
    var verse: String?
    weak var delegate: BibleControllerOutputProtocol?

    init(read: Read, verse: String) {
        super.init(node: bibleView)

        self.read = read
        self.verse = verse
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theme = Preferences.currentTheme()
        setTranslucentNavigation(false, color: theme.navBarColor, tintColor: theme.navBarTextColor, titleColor: theme.navBarTextColor)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.clipsToBounds = true
        
        let path = UIBezierPath(roundedRect: (navigationController?.navigationBar.bounds)!, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 6, height: 6))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.navigationController?.navigationBar.layer.mask = maskLayer
        
        self.view.layer.cornerRadius = 6
        self.view.clipsToBounds = true
        self.view.backgroundColor = theme.backgroundColor
        self.bibleView.webView.isOpaque = false
        
        let closeButton = UIBarButtonItem(image: R.image.iconNavbarClose(), style: .done, target: self, action: #selector(closeAction(sender:)))
        closeButton.accessibilityIdentifier = "dismissBibleVerse"
        navigationItem.leftBarButtonItem = closeButton

        let versionName = presenter?.interactor?.preferredBibleVersionFor(bibleVerses: (self.read?.bible)!) ?? ""

        versionButton = UIButton(type: .custom)
        versionButton.setAttributedTitle(AppStyle.Base.Text.navBarButton(string: versionName, color: theme.navBarTextColor), for: .normal)
        versionButton.setImage(R.image.bulletArrowDown()?.fillAlpha(fillColor: theme.navBarTextColor), for: .normal)
        versionButton.addTarget(self, action: #selector(changeVersionAction(sender:)), for: .touchUpInside)
        versionButton.centerTextAndImage(spacing: 4)
        versionButton.imageOnRight()
        versionButton.sizeToFit()

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: versionButton)

        presenter?.configure()
        presenter?.presentBibleVerse(read: self.read!, verse: self.verse!)
        UIMenuController.shared.menuItems = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didDismissBibleScreen()
    }

    @objc func closeAction(sender: UIBarButtonItem) {
        SwiftEntryKit.dismiss()
    }

    @objc func changeVersionAction(sender: UIBarButtonItem) {
        let versionName = presenter?.interactor?.preferredBibleVersionFor(bibleVerses: (self.read?.bible)!) ?? ""
        var menuitems = [MenuItem]()

        (self.read?.bible)!.forEach { item in
            let menuItem = MenuItem(
                name: item.name,
                subtitle: nil,
                image: nil,
                selected: versionName == item.name
            )
            menuitems.append(menuItem)
        }

        let menu = BibleVersionController(withItems: menuitems)
        menu.delegate = self
        var size = CGSize(width: view.window!.frame.width*0.8, height: CGFloat((self.read?.bible)!.count) * MenuItem.height + CGFloat((self.read?.bible)!.count))
        if Helper.isPad {
            size.width = round(node.frame.width*0.3)
        }
        menu.preferredContentSize = size
        menu.modalPresentationStyle = .popover
        menu.modalTransitionStyle = .crossDissolve
        menu.popoverPresentationController?.sourceView = versionButton!
        menu.popoverPresentationController?.sourceRect = CGRect.init(x: 0, y: 0, width: versionButton.frame.size.width, height: versionButton.frame.size.height)
        menu.popoverPresentationController?.delegate = menu
        menu.popoverPresentationController?.backgroundColor = AppStyle.Base.Color.background
        menu.popoverPresentationController?.permittedArrowDirections = .up
        present(menu, animated: true, completion: nil)
    }
}

extension BibleController: BibleControllerProtocol {
    func showBibleVerse(content: String) {
        bibleView.loadContent(content: content)
    }
}

extension BibleController: BibleVersionControllerDelegate {
    func didSelectVersion(versionName: String) {
        Preferences.userDefaults.set(versionName, forKey: Preferences.getPreferredBibleVersionKey())

        presenter?.presentBibleVerse(read: self.read!, verse: self.verse!)

        versionButton.setAttributedTitle(AppStyle.Base.Text.navBarButton(string: versionName), for: .normal)
        versionButton.sizeToFit()
    }
}
