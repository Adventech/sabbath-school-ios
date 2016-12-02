//
//  LanguagesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 08/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Unbox
import Wrap

protocol LanguagesViewControllerDelegate: class {
    func languagesDidSelect(language: QuarterlyLanguage)
}

class LanguagesViewController: ASViewController<ASDisplayNode> {
    var delegate: LanguagesViewControllerDelegate?
    var tableNode: ASTableNode { return node as! ASTableNode}
    var dataSource = [QuarterlyLanguage]()
    let selectedLanguage = UserDefaults.standard.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? [String: Any]
    
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
        
        setTranslucentNavigation(false, color: .tintColor, tintColor: .white, titleColor: .white)
    }
}

// MARK: - ASTableDataSource

extension LanguagesViewController: ASTableDataSource {
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let language = dataSource[indexPath.row]
        let locale = Locale(identifier: language.code)
        let currentLocale = Locale.current
        let originalName = locale.localizedString(forLanguageCode: language.code) ?? ""
        let translatedName = currentLocale.localizedString(forLanguageCode: language.code) ?? ""
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            let cell = LanguageCellNode(
                title: originalName.capitalized,
                subtitle: translatedName.capitalized
            )
            
            if let selectedLanguage = self.selectedLanguage {
                let current: QuarterlyLanguage = try! unbox(dictionary: selectedLanguage)
                cell.isSelected = language.code == current.code
            }
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
        dismiss()
        
        let dictionary: [String: Any] = try! wrap(language)
        UserDefaults.standard.set(dictionary, forKey: Constants.DefaultKey.quarterlyLanguage)
    }
}
