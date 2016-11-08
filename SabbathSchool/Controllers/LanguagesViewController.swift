//
//  LanguagesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 08/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol LanguagesViewControllerDelegate: class {
    func languagesDidSelect(language: QuarterlyLanguage)
}

class LanguagesViewController: ASViewController<ASDisplayNode> {
    var delegate: LanguagesViewControllerDelegate?
    var tableNode: ASTableNode { return node as! ASTableNode}
    var dataSource = [QuarterlyLanguage]()
    
    // MARK: - Init
    
    init(languages: [QuarterlyLanguage]) {
        super.init(node: ASTableNode())
        
        dataSource = languages
        
        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Languages".uppercased()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTranslucentNavigation(false, color: .tintColor, tintColor: .white, titleColor: .white, andFont: R.font.latoMedium(size: 15)!)
    }
}

// MARK: - ASTableDataSource

extension LanguagesViewController: ASTableDataSource {
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let language = dataSource[indexPath.row]
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            let cell = ASTextCellNode()
            cell.text = language.name
            cell.textAttributes = TextStyles.languageTitleStyle()
            cell.textInsets = UIEdgeInsets(top: 13, left: 15, bottom: 13, right: 15)
            return cell
        }
        
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

// MARK: - ASTableDelegate

extension LanguagesViewController: ASTableDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = dataSource[indexPath.row]
        delegate?.languagesDidSelect(language: language)
        UserDefaults.standard.set(language.code, forKey: Constants.DefaultKey.quarterlyLanguage)
        dismiss()
    }
}
