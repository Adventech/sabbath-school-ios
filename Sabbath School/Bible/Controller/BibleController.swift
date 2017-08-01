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

class BibleController: ASViewController<ASDisplayNode> {
    var presenter: BiblePresenterProtocol?
    var bibleView = BibleView()
    var versionButton: UIButton!
    let animator = PopupTransitionAnimator()

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

        let theme = currentTheme()
        setTranslucentNavigation(color: theme.navBarColor, tintColor: theme.navBarTextColor, titleColor: theme.navBarTextColor)

        let closeButton = UIBarButtonItem(image: R.image.iconNavbarClose(), style: .done, target: self, action: #selector(closeAction(sender:)))
        closeButton.accessibilityIdentifier = "dismissBibleVerse"
        navigationItem.leftBarButtonItem = closeButton

        let versionName = presenter?.interactor?.preferredBibleVersionFor(bibleVerses: (self.read?.bible)!) ?? ""

        versionButton = UIButton(type: .custom)
        versionButton.setAttributedTitle(TextStyles.navBarButtonStyle(string: versionName), for: .normal)
        versionButton.setImage(R.image.bulletArrowDown(), for: .normal)
        versionButton.addTarget(self, action: #selector(changeVersionAction(sender:)), for: .touchUpInside)
        versionButton.centerTextAndImage(spacing: 4)
        versionButton.imageOnRight()
        versionButton.sizeToFit()

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: versionButton)

        presenter?.configure()
        presenter?.presentBibleVerse(read: self.read!, verse: self.verse!)
        UIMenuController.shared.menuItems = []
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didDismissBibleScreen()
    }

    func closeAction(sender: UIBarButtonItem) {
        dismiss()
    }

    func changeVersionAction(sender: UIBarButtonItem) {
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

        animator.style = .arrow
        animator.fromView = versionButton

        let menu = BibleVersionController(withItems: menuitems)
        menu.delegate = self
        menu.preferredContentSize = CGSize(width: view.window!.frame.width, height: CGFloat((self.read?.bible)!.count) * MenuItem.height)
        menu.transitioningDelegate = animator
        menu.modalPresentationStyle = .custom
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
        UserDefaults.standard.set(versionName, forKey: Constants.DefaultKey.preferredBibleVersion)

        presenter?.presentBibleVerse(read: self.read!, verse: self.verse!)

        versionButton.setAttributedTitle(TextStyles.navBarButtonStyle(string: versionName), for: .normal)
        versionButton.sizeToFit()
    }
}
