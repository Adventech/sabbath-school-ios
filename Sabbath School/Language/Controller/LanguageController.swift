//
//  LanguageController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit
import Unbox

final class LanguageController: TableController {
    var presenter: LanguagePresenterProtocol & LanguageInteractorOutputProtocol = LanguagePresenter()
    var dataSource = [QuarterlyLanguage]()
    
    override init() {
        super.init()
        
        tableNode.dataSource = self
        title = "Languages".uppercased()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.configure()
        setTranslucentNavigation(false, color: .tintColor, tintColor: .white, titleColor: .white)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = dataSource[indexPath.row]
        
        presenter.didSelectLanguage(language: language)
    }
}

extension LanguageController: LanguageControllerProtocol {
    func showLanguages(languages: [QuarterlyLanguage]) {
        self.dataSource = languages
        self.tableNode.reloadData()
        self.tableNode.allowsSelection = true
    }
}

extension LanguageController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let language = dataSource[indexPath.row]
        let locale = Locale(identifier: language.code)
        let currentLocale = Locale.current
        let originalName = locale.localizedString(forLanguageCode: language.code) ?? ""
        let translatedName = currentLocale.localizedString(forLanguageCode: language.code) ?? ""
        let savedLanguage = UserDefaults.standard.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? [String: Any]
        
        let cellNodeBlock: () -> ASCellNode = {
            let cell = LanguageCellNode(
                title: originalName.capitalized,
                subtitle: translatedName.capitalized
            )
            
            if let selectedLanguage = savedLanguage {
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
