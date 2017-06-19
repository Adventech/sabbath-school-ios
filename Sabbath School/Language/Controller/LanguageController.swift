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
import UIKit
import Unbox

final class LanguageController: TableController {
    var presenter: LanguagePresenterProtocol & LanguageInteractorOutputProtocol = LanguagePresenter()
    var dataSource = [QuarterlyLanguage]()
    
    override init() {
        super.init()
        
        tableNode.dataSource = self
        title = "Languages".localized().uppercased()
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
