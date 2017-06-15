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
    
    init() {
        super.init(node: SettingsView(style: .grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Settings".uppercased()
        
        titles = [
            ["Theme", "Typeface", "Font Size"],
            ["Reminder", "Time"],
            ["Instagram", "Facebook", "GitHub", "About"],
            ["Log out"]
        ]
        
        sections = [
            "Reading Options", "Reminder", "About", ""
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTranslucentNavigation(false, color: .white, tintColor: .baseGray5, titleColor: .baseGray5)
        if let selected = tableNode.indexPathForSelectedRow {
            tableNode.view.deselectRow(at: selected, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension SettingsController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let text = titles[indexPath.section][indexPath.row]
        
        let cellNodeBlock: () -> ASCellNode = {
            return SettingsItemView(text: text, showDisclosure: false)
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
            let header = UIView()
            
            let copyrightImage = UIImageView(image: R.image.bulletArrowDown())
            copyrightImage.center = tableView.center
            header.addSubview(copyrightImage)
            
            var imageframe = copyrightImage.frame
            imageframe.origin.y = 34
            copyrightImage.frame = imageframe
            
            let versionY = copyrightImage.frame.height+copyrightImage.frame.origin.y
            let versionLabel = UILabel(frame: CGRect(x: 0, y: versionY, width: view.frame.width, height: 18))
            versionLabel.textAlignment = .center
            versionLabel.attributedText = TextStyles.settingsFooterCopyrightStyle(string: "yo")
            header.addSubview(versionLabel)
            
            return header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sections.count-1 {
            return 100
        } else {
            return 20
        }
    }
    
    func getAppVersionText() -> String {
        var versionText = NSLocalizedString("settings.version", comment: "")
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionText = "\(versionText) \(version)"
        }
        return versionText
    }
}
