/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

class QuarterlyController: QuarterlyControllerCommon {
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override init() {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Preferences.gcPopupStatus() {
            Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.gcPopup)
            presenter?.presentGCScreen()
        } else if initiateOpen ?? false {
            let lastQuarterlyIndex = Preferences.currentQuarterly()
            let languageCode = lastQuarterlyIndex.components(separatedBy: "-")
            if let code = languageCode.first, Preferences.currentLanguage().code == code {
                presenter?.presentLessonScreen(quarterlyIndex: lastQuarterlyIndex, initiateOpenToday: false)
            }
        }
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
        scrollBehavior()
    }
    
    private func setupNavigationBar() {
        let settingsButton = UIBarButtonItem(image: R.image.iconNavbarSettings(), style: .done, target: self, action: #selector(showSettings))
        settingsButton.accessibilityIdentifier = "openSettings"

        let languagesButton = UIBarButtonItem(image: R.image.iconNavbarLanguage(), style: .done, target: self, action: #selector(showLanguages(sender:)))
        languagesButton.accessibilityIdentifier = "openLanguage"

        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = languagesButton
        
        setNavigationBarOpacity(alpha: 0)
        self.navigationController?.tabBarItem.title = "Sabbath School".localized()
        self.navigationController?.navigationBar.hideBottomHairline()
        self.navigationController?.navigationBar.tintColor = AppStyle.Base.Color.navigationTint
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(0)]
        self.navigationController?.navigationBar.barTintColor = nil
    }
    
    @objc func showSettings() {
        let settings = SettingsController()

        let nc = ASNavigationController(rootViewController: settings)
        self.present(nc, animated: true)
    }
    
    @objc func showLanguages(sender: UIBarButtonItem) {
        presenter?.presentLanguageScreen()
    }
}
