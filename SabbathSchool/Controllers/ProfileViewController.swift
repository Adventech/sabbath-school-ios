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

class ProfileViewController: ASViewController<ASDisplayNode> {
    var tableNode: ASTableNode { return node as! ASTableNode}
    
    // MARK: - Init
        
    init() {
        super.init(node: ASTableNode())
//        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Profile".uppercased()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(leftAction))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    // MARK: -
    
    func leftAction() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.logoutAnimated()
    }
}

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
