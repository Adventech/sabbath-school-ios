//
//  ProfileViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 23/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase

final class ProfileViewController: ASViewController<ASDisplayNode> {
    var tableNode: ASTableNode { return node as! ASTableNode}
    
    // MARK: - Init
        
    init() {
        super.init(node: ASTableNode())
//        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Profile".uppercased()
        tabBarItem.image = R.image.iconProfile()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutAction))
        let settingsButton = UIBarButtonItem(image: R.image.iconNavbarSettings(), style: .done, target: self, action: #selector(settingsAction))
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTranslucentNavigation(true, color: .tintColor, tintColor: .white, titleColor: .white)
    }
    
    // MARK: - NavBar Actions
    
    func logoutAction() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.logoutAnimated()
    }
    
    func settingsAction() {
        print("settings")
    }
    
    // MARK: - Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: ASTableDataSource

extension ProfileViewController: ASTableDataSource {

    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            guard let user = FIRAuth.auth()?.currentUser else {
                return ASCellNode()
            }
            
            let cell = ProfileUserCellNode(name: user.displayName ?? "", avatar: user.photoURL)
            return cell
        }
        
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
