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
import FirebaseAuth
import JSQWebViewController
import SafariServices
import SwiftDate
import UIKit

class SettingsController: ASViewController<ASDisplayNode> {
    weak var tableNode: SettingsView? { return node as? SettingsView }

    fileprivate let pickerView = PickerViewController()
    fileprivate let popupAnimator = PopupTransitionAnimator()

    var titles = [[String]]()
    var sections = [String]()
    var footers = [String]()

    init() {
        super.init(node: SettingsView(style: .grouped))
        tableNode?.delegate = self
        tableNode?.dataSource = self

        title = "Settings".localized().uppercased()

        titles = [
            ["Reminder".localized()],
            ["🐙 GitHub".localized()],
            ["🙏 About us".localized(), "💌 Recommend Sabbath School".localized(), "🎉 Rate app".localized()],
            ["Log out".localized()]
        ]

        if reminderStatus() {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTranslucentNavigation(false, color: .tintColor, tintColor: .white, titleColor: .white)
        if let selected = tableNode?.indexPathForSelectedRow {
            tableNode?.view.deselectRow(at: selected, animated: true)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func reminderChanged(sender: UISwitch) {
        let isOn = sender.isOn

        guard isOn else {
            titles[0].remove(at: 1)
            self.tableNode?.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
            UserDefaults.standard.set(false, forKey: Constants.DefaultKey.settingsReminderStatus)
            UIApplication.shared.cancelAllLocalNotifications()
            return
        }

        titles[0].append("Time".localized())
        UserDefaults.standard.set(true, forKey: Constants.DefaultKey.settingsReminderStatus)

        SettingsController.setUpLocalNotification()
        self.tableNode?.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
    }

    static func setUpLocalNotification() {
        UIApplication.shared.cancelAllLocalNotifications()
        let time = try! DateInRegion(string: reminderTime(), format: .custom("HH:mm"))
        let hour = time.hour
        let minute = time.minute
        let calendar = NSCalendar(identifier: .gregorian)! // have to use NSCalendar for the components

        var dateFire = Date()

        // if today's date is passed, use tomorrow
        var fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire)

        if fireComponents.hour! > hour || (fireComponents.hour == hour && fireComponents.minute! >= minute) {
            dateFire = dateFire.addingTimeInterval(86400)  // Use tomorrow's date
            fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire)
        }

        // set up the time
        fireComponents.hour = hour
        fireComponents.minute = minute

        // schedule local notification
        dateFire = calendar.date(from: fireComponents)!

        let localNotification = UILocalNotification()
        localNotification.fireDate = dateFire
        localNotification.alertBody = "Time to study Sabbath School 🙏".localized()
        localNotification.repeatInterval = NSCalendar.Unit.day
        localNotification.soundName = UILocalNotificationDefaultSoundName

        UIApplication.shared.scheduleLocalNotification(localNotification)

    }
}

extension SettingsController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let text = titles[indexPath.section][indexPath.row]

        let cellNodeBlock: () -> ASCellNode = {
            var settingsItem = SettingsItemView(text: text)

            if indexPath.row == 0 && indexPath.section == 0 {
                settingsItem = SettingsItemView(text: text, switchState: true)
                settingsItem.selectionStyle = .none

                DispatchQueue.main.async { [weak self] in
                    settingsItem.switchView.setOn(reminderStatus(), animated: false)
                    settingsItem.switchView.addTarget(self, action: #selector(self?.reminderChanged(sender:)), for: .valueChanged)
                }
            }

            if indexPath.row == 0 && indexPath.section == 2 {
                settingsItem = SettingsItemView(text: text, showDisclosure: true)
            }

            if indexPath.row == 1 && indexPath.section == 0 {
                let time = try! DateInRegion(string: reminderTime(), format: .custom("HH:mm"))
                settingsItem = SettingsItemView(text: text, detailText: time.string(dateStyle: .none, timeStyle: .short))
                settingsItem.contentStyle = .detailOnRight
            }

            if indexPath.section == 3 {
                settingsItem = SettingsItemView(text: text, destructive: true)
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
}

extension SettingsController: PickerViewControllerDelegate {
    func pickerView(_ pickerView: PickerViewController, didChangedToDate date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        UserDefaults.standard.set(dateFormatter.string(from: date), forKey: Constants.DefaultKey.settingsReminderTime)
        self.tableNode?.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        SettingsController.setUpLocalNotification()
    }
}

extension SettingsController: ASTableDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableNode?.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 {
                let cell = tableNode?.view.nodeForRow(at: indexPath) as! SettingsItemView
                pickerView.delegate = self
                pickerView.datePicker.datePickerMode = .time

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                pickerView.datePicker.date = dateFormatter.date(from: reminderTime())!

                pickerView.modalPresentationStyle = .custom
                let width: CGFloat = traitCollection.horizontalSizeClass == .compact ? node.bounds.width : 500
                pickerView.preferredContentSize = CGSize(width: width, height: 200)
                pickerView.transitioningDelegate = popupAnimator
                popupAnimator.fromView = cell.textNode.view
                popupAnimator.overlayColor = UIColor(white: 0, alpha: 0.2)
                present(pickerView, animated: true, completion: nil)
            }
            break
        case 1:
            let url = "https://github.com/Adventech"

            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: url)!)
                safariVC.view.tintColor = .tintColor
                safariVC.modalPresentationStyle = .currentContext
                present(safariVC, animated: true, completion: nil)
            } else {
                let controller = WebViewController(url: URL(string: url)!)
                let nav = UINavigationController(rootViewController: controller)
                present(nav, animated: true, completion: nil)
            }

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
                activityController.popoverPresentationController?.permittedArrowDirections = .any

                present(activityController, animated: true, completion: nil)
            }

            if indexPath.row == 2 {
                UIApplication.shared.openURL(NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=895272167&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software")! as URL)
            }
            break

        case 3:
            try! Auth.auth().signOut()
            QuarterlyWireFrame.presentLoginScreen()
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

        headerLabel.attributedText = TextStyles.settingsHeaderStyle(string: sections[section])

        let header = UIView()

        header.addSubview(headerLabel)
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == sections.count-1 {
            let versionLabel = UILabel(frame: CGRect(x: 0, y: 34, width: view.frame.width, height: 18))
            versionLabel.textAlignment = .center
            versionLabel.attributedText = TextStyles.settingsFooterCopyrightStyle(string: "Made with ❤ by Adventech".localized())
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
}
