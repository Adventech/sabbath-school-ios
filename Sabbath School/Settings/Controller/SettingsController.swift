//
//  SettingsController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-13.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class SettingsController: ASViewController<ASDisplayNode> {
    var tableNode: SettingsView { return node as! ASTableNode as! SettingsView }
    
    var titles = [[String]]()
    var sections = [String]()
    var footers = [String]()
    
    init() {
        super.init(node: SettingsView(style: .grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Settings".uppercased()
        
        titles = [
            ["Reminder", "Time"],
            ["🐙 GitHub"],
            ["🤠 About us", "💌 Recommend Sabbath School", "🎉 Rate app"],
            ["Log out"]
        ]
        
        sections = [
            "Reminder",
            "Contribute",
            "More",
            ""
        ]
        
        footers = [
            "Set the reminder to be notified daily to study the lesson",
            "Our apps are Open Source, including Sabbath School. Check out our GitHub if you would like to contribute",
            ""
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTranslucentNavigation(false, color: .tintColor, tintColor: .white, titleColor: .white)
        if let selected = tableNode.indexPathForSelectedRow {
            tableNode.view.deselectRow(at: selected, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SettingsController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let text = titles[indexPath.section][indexPath.row]
        
        let cellNodeBlock: () -> ASCellNode = {
            var settingsItem = SettingsItemView(text: text, showDisclosure: false)
            
            if indexPath.row == 0 && indexPath.section == 0 {
                settingsItem = SettingsItemView(text: text, switchState: true)
            }
            
            if indexPath.row == 1 && indexPath.section == 0 {
                settingsItem = SettingsItemView(text: text, detailText: "8:00 AM")
                settingsItem.contentStyle = .detailOnRight
            }
            
            if indexPath.section == 3 {
                settingsItem = SettingsItemView(text: text, destructive: true)
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

extension SettingsController: ASTableDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            print("YOU")
        default:
            break
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == sections.count-1 {
            let versionLabel = UILabel(frame: CGRect(x: 0, y: 34, width: view.frame.width, height: 18))
            versionLabel.textAlignment = .center
            versionLabel.attributedText = TextStyles.settingsFooterCopyrightStyle(string: "Made with ❤ by Adventech")
            return versionLabel
        } else {
            if footers[section].isEmpty { return nil }
            return getLabelForSectionFooter(section: section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sections.count-1 {
            return 100
        } else {
            if footers[section].isEmpty { return 20 }
            return getLabelForSectionFooter(section: section).frame.size.height + 20
        }
    }
    
    func getLabelForSectionFooter(section: Int) -> UIView {
        let footerView = UIView()
        let footerLabel = UILabel(frame: CGRect(x: 15, y: 10, width: view.frame.width-20, height: 0))
        footerLabel.numberOfLines = 0
        footerLabel.attributedText = TextStyles.settingsFooterStyle(string: footers[section])
        footerLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        footerLabel.sizeToFit()
        footerView.addSubview(footerLabel)
        footerView.frame.size.height = footerLabel.frame.size.height
        return footerView
    }
    
    func getAppVersionText() -> String {
        var versionText = NSLocalizedString("settings.version", comment: "")
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionText = "\(versionText) \(version)"
        }
        return versionText
    }
}
