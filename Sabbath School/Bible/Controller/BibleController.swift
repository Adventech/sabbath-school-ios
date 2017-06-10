//
//  BibleController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class BibleController: ASViewController<ASDisplayNode> {
    var presenter: BiblePresenterProtocol?
    var bibleView = BibleView()
    var versionButton: UIButton!
    let animator = PopupTransitionAnimator()
    
    var read: Read?
    var verse: String?
    
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
        if theme == ReaderStyle.Theme.Dark {
            setTranslucentNavigation(true, color: .readerDark, tintColor: .readerDarkFont, titleColor: .readerDarkFont)
        } else {
            setTranslucentNavigation(true, color: .tintColor, tintColor: .white, titleColor: .white)
        }
        
        let closeButton = UIBarButtonItem(image: R.image.iconNavbarClose(), style: .done, target: self, action: #selector(closeAction(sender:)))
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
    func showBibleVerse(content: String){
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
