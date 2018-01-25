/*
 * Copyright (c) 2018 Adventech <info@adventech.io>
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

import UIKit
import AsyncDisplayKit

class QuarterlySettingsController: ASViewController<ASDisplayNode> {

    weak var tableNode: SettingsView? { return node as? SettingsView }
    var selectedIndexPath: IndexPath?
    
    var titles = [[String]]()
    var sections = [String]()
    
     init() {
        super.init(node: SettingsView(style: .grouped))
        tableNode?.delegate = self
        tableNode?.dataSource = self
        
        title = "Quarterly".uppercased().localized()
       
        if currentLanguage().code == "en" {
            titles = [["Adult".localized(), "Collegiate".localized()]]
        } else {
            titles = [["Adult".localized()]]
        }
        sections = [
            "Preferred Quarterly".localized(),
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
    }
}

extension QuarterlySettingsController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UserDefaults.standard.set(QuarterlyType.adult.rawValue, forKey: Constants.DefaultKey.settingQuarterlyType)
        } else {
            UserDefaults.standard.set(QuarterlyType.collegiate.rawValue, forKey: Constants.DefaultKey.settingQuarterlyType)
        }
        
        tableNode.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != selectedIndexPath?.row  else { return }

        tableNode.cellForRow(at: indexPath)?.accessoryType = .checkmark

        if selectedIndexPath != nil {
            tableNode.cellForRow(at: selectedIndexPath!)?.accessoryType = .none
        }
        
        selectedIndexPath = indexPath
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        tableNode.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

extension QuarterlySettingsController: ASTableDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 15, y: section == 0 ?32:14, width: view.frame.width, height: 20))
        headerLabel.attributedText = TextStyles.settingsHeaderStyle(string: sections[section])
        
        let header = UIView()
        
        header.addSubview(headerLabel)
        return header
    }
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let text = titles[indexPath.section][indexPath.row]
        
        let cellNodeBlock: () -> ASCellNode = {
            let settingsItem = SettingsItemView(text: text)
            
            if indexPath.row == 0 {
                if currentQuarterlyType() == .adult {
                    settingsItem.accessoryType = .checkmark
                    self.selectedIndexPath = indexPath
                }
            } else if indexPath.row == 1 {
                if currentQuarterlyType() == .collegiate {
                    settingsItem.accessoryType = .checkmark
                    self.selectedIndexPath = indexPath
                }
            }
            
            return settingsItem
        }
        
        return cellNodeBlock
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
}
