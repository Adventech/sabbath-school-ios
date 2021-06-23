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

import AuthenticationServices
import AsyncDisplayKit
import FirebaseAuth
import SafariServices
import SwiftDate
import UIKit

class SettingsController: ASDKViewController<ASDisplayNode> {
    weak var tableNode: SettingsView? { return node as? SettingsView }

    fileprivate let pickerView = PickerViewController()
    fileprivate let dateFormatter = DateFormatter()

    var titles = [[String]]()
    var sections = [String]()
    var footers = [String]()

    override init() {
        super.init(node: SettingsView(style: .grouped))
        dateFormatter.dateFormat = "HH:mm"
        tableNode?.delegate = self
        tableNode?.dataSource = self
        tableNode?.backgroundColor = AppStyle.Base.Color.background

        title = "Settings".localized().uppercased()

        titles = [
            ["Reminder".localized()],
            ["🐙 GitHub".localized()],
            ["🙏 About us".localized(), "💌 Recommend Sabbath School".localized(), "🎉 Rate app".localized()],
            ["Log out".localized()]
        ]

        if Preferences.reminderStatus() {
            titles[0].append("Time".localized())
        }

        sections = [
            "Reminder".localized(),
            "Contribute".localized(),
            "More".localized(),
            ""
        ]

        footers = [
            "Set the reminder to be notified daily to study the lesson".localized(),
            "Our apps are Open Source, including Sabbath School. Check out our GitHub if you would like to contribute".localized(),
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableNode?.view.separatorColor = AppStyle.Base.Color.tableSeparator
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if UIApplication.shared.applicationState != .background && self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                tableNode?.backgroundColor = AppStyle.Base.Color.background
                tableNode?.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTranslucentNavigation(false, color: AppStyle.Base.Color.tint, tintColor: .white, titleColor: .white)
        if let selected = tableNode?.indexPathForSelectedRow {
            tableNode?.view.deselectRow(at: selected, animated: true)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func logOut(presentLoginScreen: Bool = true) {
        if let providerId = Auth.auth().currentUser?.providerData.first?.providerID, providerId == "apple.com" {
            Preferences.userDefaults.set(nil, forKey: Constants.DefaultKey.appleAuthorizedUserIdKey)
        }
        
        UIApplication.shared.shortcutItems = []
        Spotlight.clearSpotlight()
        
        try! Auth.auth().signOut()
        if presentLoginScreen {
            DispatchQueue.main.async {
                QuarterlyWireFrame.presentLoginScreen()
            }
        }
    }

    @objc func reminderChanged(sender: UISwitch) {
        let isOn = sender.isOn

        guard isOn else {
            // iOS 9 crashes during press hold /drag of the switch, therefore double-checking before removing time row
            if titles[0].indices.contains(1) {
                titles[0].remove(at: 1)
                self.tableNode?.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                Preferences.userDefaults.set(false, forKey: Constants.DefaultKey.settingsReminderStatus)
                UIApplication.shared.cancelAllLocalNotifications()
            }
            return
        }

        // iOS 9 crashes during press hold /drag of the switch, therefore double-checking before adding time row
        if (titles[0].count < 2) {
            titles[0].append("Time".localized())
            Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.settingsReminderStatus)

            SettingsController.setUpLocalNotification()
            self.tableNode?.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        }
    }

    static func setUpLocalNotification() {
        UIApplication.shared.cancelAllLocalNotifications()
        let time = DateInRegion(Preferences.reminderTime(), format: "HH:mm")
        let hour = time?.hour ?? 0
        let minute = time?.minute ?? 0
        let calendar = NSCalendar(identifier: .gregorian)!

        var dateFire = Date()
        var fireComponents = calendar.components( [.day, .month, .year, .hour, .minute], from:dateFire)

        if fireComponents.hour! > hour || (fireComponents.hour == hour && fireComponents.minute! >= minute) {
            dateFire = dateFire.addingTimeInterval(86400)
            fireComponents = calendar.components( [.day, .month, .year, .hour, .minute], from:dateFire)
        }

        fireComponents.hour = hour
        fireComponents.minute = minute

        dateFire = calendar.date(from: fireComponents)!

        let localNotification = UILocalNotification()
        
        localNotification.fireDate = dateFire
        localNotification.alertBody = "Time to study Sabbath School 🙏".localized()
        localNotification.repeatInterval = .day
        localNotification.soundName = UILocalNotificationDefaultSoundName

        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
}

extension SettingsController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let title = titles[indexPath.section][indexPath.row]

        let cellNodeBlock: () -> ASCellNode = {
            var settingsItem = SettingsItemView(title: title)

            if indexPath.row == 0 && indexPath.section == 0 {
                settingsItem = SettingsItemView(title: title, switchState: true)
                settingsItem.selectionStyle = .none

                DispatchQueue.main.async { [weak self] in
                    settingsItem.switchView.setOn(Preferences.reminderStatus(), animated: false)
                    settingsItem.switchView.addTarget(self, action: #selector(self?.reminderChanged(sender:)), for: .valueChanged)
                }
            }

            if indexPath.row == 0 && indexPath.section == 2 {
                settingsItem = SettingsItemView(title: title, showDisclosure: true)
            }

            if indexPath.row == 1 && indexPath.section == 0 {
                if #available(iOS 13.4, *) {
                    let datePickerTime = Preferences.reminderTime()
                    settingsItem = SettingsItemView(title: title, datePicker: true)
                    
                    DispatchQueue.main.async { [self] in
                        settingsItem.datePickerView.datePickerMode = .time
                        settingsItem.datePickerView.date = self.dateFormatter.date(from: datePickerTime)!
                        settingsItem.datePickerView.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: .valueChanged)
                    }
                } else {
                    let time = DateInRegion(Preferences.reminderTime(), format: "HH:mm")
                    settingsItem = SettingsItemView(title: title, detail: time?.toString(.time(.short)) ?? "")
                    settingsItem.contentStyle = .right
                }
            }

            if indexPath.section == 3 {
                settingsItem = SettingsItemView(title: title, danger: true)
                settingsItem.accessibilityIdentifier = "logOut"
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
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        self.saveReminderTime(date: sender.date)
    }
    
    func saveReminderTime(date: Date) {
        Preferences.userDefaults.set(dateFormatter.string(from: date), forKey: Constants.DefaultKey.settingsReminderTime)
        SettingsController.setUpLocalNotification()
    }
}

extension SettingsController: PickerViewControllerDelegate {
    func pickerView(_ pickerView: PickerViewController, didChangedToDate date: Date) {
        self.saveReminderTime(date: date)
        self.tableNode?.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
    }
}

extension SettingsController: ASTableDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableNode?.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 {
                if #available(iOS 13.4, *) {} else {
                    let settingsItemView = tableNode?.view.nodeForRow(at: indexPath) as! SettingsItemView
                    pickerView.delegate = self
                    pickerView.datePicker.datePickerMode = .time

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    pickerView.datePicker.date = dateFormatter.date(from: Preferences.reminderTime())!

                    pickerView.modalPresentationStyle = .custom
                    let width: CGFloat = traitCollection.horizontalSizeClass == .compact ? node.bounds.width : 500
                    pickerView.preferredContentSize = CGSize(width: width, height: 200)
                    
                    
                    pickerView.modalPresentationStyle = .popover
                    pickerView.modalTransitionStyle = .crossDissolve
                    pickerView.popoverPresentationController?.sourceView = settingsItemView.detail.view
                    pickerView.popoverPresentationController?.sourceRect = CGRect.init(x: 0, y: 0, width: settingsItemView.detail.view.frame.size.width, height: settingsItemView.detail.view.frame.size.height)
                    pickerView.popoverPresentationController?.delegate = pickerView
                    pickerView.popoverPresentationController?.backgroundColor = AppStyle.Base.Color.background
                    pickerView.popoverPresentationController?.permittedArrowDirections = .up
                    present(pickerView, animated: true, completion: nil)
                }
            }
            break
        case 1:
            let url = "https://github.com/Adventech"
            let safariVC = SFSafariViewController(url: URL(string: url)!)
            safariVC.view.tintColor = AppStyle.Base.Color.tint
            safariVC.modalPresentationStyle = .currentContext
            present(safariVC, animated: true, completion: nil)

            break
        case 2:
            if indexPath.row == 0 {
                let about = AboutController()
                show(about, sender: nil)
            }

            if indexPath.row == 1 {
                let objectsToShare = ["I am using Sabbath School app from Adventech! 🎉".localized(), "https://itunes.apple.com/ca/app/sabbath-school/id895272167?mt=8"]
                let activityController = UIActivityViewController(
                    activityItems: objectsToShare,
                    applicationActivities: nil)

                activityController.popoverPresentationController?.sourceRect = view.frame
                activityController.popoverPresentationController?.sourceView = view
                if Helper.isPad {
                    activityController.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
                }
                activityController.popoverPresentationController?.permittedArrowDirections = .any

                present(activityController, animated: true, completion: nil)
            }

            if indexPath.row == 2 {
                UIApplication.shared.openURL(NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=895272167&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software")! as URL)
            }
            break

        case 3:
            SettingsController.logOut()
            break
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 15, y: section == 0 ?32:14, width: view.frame.width, height: 20))

        headerLabel.attributedText = AppStyle.Settings.Text.header(string: sections[section])

        let header = UIView()

        header.addSubview(headerLabel)
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == sections.count-1 {
            let versionLabel = UILabel(frame: CGRect(x: 0, y: 34, width: view.frame.width, height: 18))
            versionLabel.textAlignment = .center
            versionLabel.attributedText = AppStyle.Settings.Text.copyright(string: "Made with ❤ by Adventech".localized())
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
        footerLabel.attributedText = AppStyle.Settings.Text.footer(string: footers[section])
        footerLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        footerLabel.sizeToFit()
        footerView.addSubview(footerLabel)
        footerView.frame.size.height = footerLabel.frame.size.height
        return footerView
    }
}
