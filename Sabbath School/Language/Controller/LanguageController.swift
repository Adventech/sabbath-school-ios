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

final class LanguageController: ASDKViewController<ASDisplayNode> {
    var presenter: LanguagePresenterProtocol & LanguageInteractorOutputProtocol = LanguagePresenter()
    var dataSource = [QuarterlyLanguage]()
    var filtered = [QuarterlyLanguage]()
    var table = ASTableNode()
    var loading: Bool = false
    let searchController = UISearchController(searchResultsController: nil)

    override init() {
        super.init(node: table)
        self.table.delegate = self
        self.table.dataSource = self
        
        title = "Languages".localized()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCloseButton()
        presenter.configure()
        setupSearch()
        
        self.navigationController?.navigationBar.tintColor = AppStyle.Base.Color.navigationTint

        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupSearch() {
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        
        if #available(iOS 11, *) {
            navigationItem.searchController = searchController
        } else {
            table.view.tableHeaderView = searchController.searchBar
        }
        
        searchController.searchBar.placeholder = "Search…".localized()
        definesPresentationContext = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if UIApplication.shared.applicationState != .background && self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.table.reloadData()
                self.table.view.separatorColor = AppStyle.Base.Color.tableSeparator
                self.table.view.backgroundColor = AppStyle.Base.Color.background
            }
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.table.contentInset.bottom = 0
        } else {
            var contentInset: UIEdgeInsets = self.table.contentInset
            contentInset.bottom = keyboardViewEndFrame.size.height
            if #available(iOS 11.0, *) {
                contentInset.bottom = contentInset.bottom - view.safeAreaInsets.bottom
            }
            self.table.contentInset = contentInset
        }
    }
}

extension LanguageController: LanguageControllerProtocol {
    func showLanguages(languages: [QuarterlyLanguage]) {
        self.dataSource = languages
        self.filtered = self.dataSource
        self.table.reloadData()
    }
}

extension LanguageController: ASTableDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = filtered[indexPath.row]
        searchController.isActive = false
        presenter.didSelectLanguage(language: language)
    }
}

extension LanguageController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            let language = self.filtered[indexPath.row]
            
            let savedLanguage = Preferences.userDefaults.value(forKey: Constants.DefaultKey.quarterlyLanguage) as? Data

            let cell = LanguageItemView(
                name: language.name,
                translated: language.translatedName!
            )

            if let selectedLanguage = savedLanguage {
                let current: QuarterlyLanguage = try! JSONDecoder().decode(QuarterlyLanguage.self, from: selectedLanguage)
                cell.isSelected = language.code == current.code
            }

            cell.accessibilityIdentifier = language.code
            return cell
        }

        return cellNodeBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
}

extension LanguageController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if self.loading { return }
        self.loading = true
        let searchText = searchController.searchBar.text!.lowercased()
        self.filtered = searchText.isEmpty ? self.dataSource : self.dataSource.filter({ $0.name.lowercased().contains(searchText) || ($0.translatedName ?? $0.name).lowercased().contains(searchText) })
        self.table.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.fade)
        self.loading = false
    }
}
