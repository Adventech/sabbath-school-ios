//
//  AboutController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-20.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import JSQWebViewController
import UIKit

class AboutController: ThemeController {
    var collectionNode: ASCollectionNode { return node as! ASCollectionNode }
    let collectionViewLayout = UICollectionViewFlowLayout()
    
    init() {
        super.init(node: ASCollectionNode(collectionViewLayout: collectionViewLayout))
        collectionNode.dataSource = self
        title = "About us".localized().uppercased()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTranslucentNavigation(false, color: .tintColor, tintColor: .white, titleColor: .white)
    }
    
    func openUrl(url: String){
        let controller = WebViewController(url: URL(string: url)!)
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
}

extension AboutController: AboutViewDelegate {
    func didTapInstagram() {
        let instagramURL:URL = URL(string: "instagram://user?username=adventech")!

        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.openURL(instagramURL)
        } else {
            self.openUrl(url: "https://instagram.com/adventech")
        }
    }
    
    func didTapFacebook() {
        let facebookURL:URL = URL(string: "fb://profile/1374916669500596")!
        
        if UIApplication.shared.canOpenURL(facebookURL) {
            UIApplication.shared.openURL(facebookURL)
        } else {
            self.openUrl(url: "https://www.facebook.com/shabbatschool/")
        }
    }
    
    func didTapGitHub() {
        self.openUrl(url: "https://github.com/Adventech")
    }
    
    func didTapWebsite() {
        self.openUrl(url: "http://www.adventech.io")
    }
}

extension AboutController: ASCollectionDataSource {
    func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode =  { [weak self] in
            let view = AboutView()
            view.delegate = self
            return view
        }
        
        return cellNodeBlock
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}
