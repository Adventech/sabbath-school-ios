//
//  BibleVersesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BibleVersesViewController: ASViewController<ASDisplayNode> {
    let versesNode = VersesNode()
    var bibleVerses: [BibleVerses]!
    let verse: String!
    let popupAnimator = PopupTransitionAnimator()
    var versionButton: UIButton!
    fileprivate var selectedVerse: String?
    
    init(bibleVerses: [BibleVerses], verse: String) {
        self.bibleVerses = bibleVerses
        self.verse = verse
        
        super.init(node: versesNode)
        
        title = NSLocalizedString("Bible", comment: "").uppercased()
        
        if let versionName = preferredBibleVersionFor(bibleVerses: bibleVerses),
            let bibleVersion = bibleVerses.filter({$0.name == versionName}).first,
            let openVerse = bibleVersion.verses[verse] {
            selectedVerse = openVerse
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let selectedVerse = selectedVerse else {
            dismiss()
            return
        }
        
        setTranslucentNavigation(false, color: .tintColor, tintColor: .white, titleColor: .white)

        // NavBar items
        createNavBarButtons()
        
        loadVerse(verse: selectedVerse)
    }
    
    // MARK: - Load verse into WebView
    
    func loadVerse(verse: String) {
        let indexPath = Bundle.main.path(forResource: "index", ofType: "html")
        var index = try? String(contentsOfFile: indexPath!, encoding: String.Encoding.utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: verse)
        index = index?.replacingOccurrences(of: "css/", with: "") // Fix the css path
        index = index?.replacingOccurrences(of: "js/", with: "") // Fix the js path
        versesNode.webView.loadHTMLString(index!, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }
    
    // MARK: - NavBar Actions
    
    func createNavBarButtons() {
        let closeButton = UIBarButtonItem(image: R.image.iconNavbarClose(), style: .done, target: self, action: #selector(closeAction(sender:)))
        navigationItem.leftBarButtonItem = closeButton
        
        let versionName = preferredBibleVersionFor(bibleVerses: bibleVerses) ?? ""
        
        versionButton = UIButton(type: .custom)
        versionButton.setAttributedTitle(TextStyles.navBarButtonStyle(string: versionName), for: .normal)
        versionButton.setImage(R.image.bulletArrowDown(), for: .normal)
        versionButton.addTarget(self, action: #selector(changeVersion(sender:)), for: .touchUpInside)
        versionButton.centerTextAndImage(spacing: 4)
        versionButton.imageOnRight()
        versionButton.sizeToFit()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: versionButton)
    }
    
    func closeAction(sender: UIBarButtonItem) {
        dismiss()
    }
    
    func changeVersion(sender: UIBarButtonItem) {
        popupAnimator.style = .arrow
        popupAnimator.fromView = versionButton
        
        var menuitems = [MenuItem]()
        
        bibleVerses.forEach { item in
            let menuItem = MenuItem(name: item.name, subtitle: nil, image: nil)
            menuitems.append(menuItem)
        }
        
        let menu = MenuViewController(withItems: menuitems)
        menu.delegate = self
        menu.preferredContentSize = CGSize(width: view.window!.frame.width, height: CGFloat(bibleVerses.count) * MenuItem.height)
        menu.transitioningDelegate = popupAnimator
        menu.modalPresentationStyle = .custom
        present(menu, animated: true, completion: nil)
    }
}

// MARK: - MenuViewControllerDelegate

extension BibleVersesViewController: MenuViewControllerDelegate {
    
    func menuView(menuView: MenuViewController, didSelectItemAtIndex index: Int) {
        let bibleVerse = bibleVerses[index]
        
        if let openVerse = bibleVerse.verses[verse] {
            loadVerse(verse: openVerse)
        }
        
        versionButton.setTitle(bibleVerse.name, for: .normal)
        versionButton.sizeToFit()
        navigationItem.setRightBarButton(UIBarButtonItem(customView: versionButton), animated: true)
        
        UserDefaults.standard.set(bibleVerse.name, forKey: Constants.DefaultKey.preferredBibleVersion)
    }
}
