/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
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

import SwiftUI
import SwiftDate

struct SettingsView: View {
    @State private var reminderTime: Date = Date.now
    @State private var reminderEnabled = Preferences.reminderStatus()
    @State private var showAboutUs = false
    @State private var showAccountRemovalAlert = false
    @State private var showRemoveDownloadsAlert = false
    
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        NavigationStack {
            SwiftUI.List {
                Section {
                    Toggle("Reminder".localized(), isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Time".localized(), selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Reminder".localized())
                } footer: {
                    Text("Set the reminder to be notified daily to study the lesson".localized())
                }.onChange(of: reminderEnabled) { newValue in
                    if !newValue {
                        Preferences.userDefaults.set(false, forKey: Constants.DefaultKey.settingsReminderStatus)
                        
                        NotificationsManager.clearLocalNotifications()
                    } else {
                        NotificationsManager.setupLocalNotifications()
                    }
                }.onChange(of: reminderTime) { newValue in
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    
                    Preferences.userDefaults.set(dateFormatter.string(from: newValue), forKey: Constants.DefaultKey.settingsReminderTime)
                    
                    NotificationsManager.setupLocalNotifications()
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/Adventech")!) {
                        Text("🐙 GitHub".localized())
                    }.accentColor(.black | .white)
                    
                } header: {
                    Text("Contribute".localized())
                } footer: {
                    Text("Our apps are Open Source, including Sabbath School. Check out our GitHub if you would like to contribute".localized())
                }
                
                Section {
                    Button(action: {
                        showAboutUs = true
                    }) {
                        Text("🙏 About us".localized())
                    }.accentColor(.black | .white)
                    
                    ShareLink(
                        item: URL(string: "https://itunes.apple.com/ca/app/sabbath-school/id895272167?mt=8")!,
                        subject: Text("I am using Sabbath School app from Adventech! 🎉".localized())
                    ) {
                        Text("💌 Recommend Sabbath School".localized())
                    }.accentColor(.black | .white)
                    
                    Link(destination: URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=895272167&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software")!) {
                        Text("🎉 Rate app".localized())
                    }.accentColor(.black | .white)
                    
                } header: {
                    Text("More".localized())
                }
                
                Section {
                    Button(action: {
                        showRemoveDownloadsAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove all downloads".localized())
                        }
                    }.alert(isPresented: $showRemoveDownloadsAlert) {
                        Alert(
                            title: Text("Remove all downloads".localized()),
                            message: Text("By removing all downloads you will lose all the lessons content currently saved offline. Are you sure you want to proceed?".localized()),
                            primaryButton: .destructive(Text("Yes".localized())) {
                                Configuration.clearAllCache()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        accountManager.logOut()
                    }) {
                        Text("Log out".localized())
                    }
                    
                    if let isAnonymous = accountManager.account?.isAnonymous,
                       !isAnonymous {
                        
                        Button(role: .destructive, action: {
                            showAccountRemovalAlert = true
                        }) {
                            Text("Account removal".localized())
                        }.alert(isPresented: $showAccountRemovalAlert) {
                            Alert(
                                title: Text("Delete account?".localized()),
                                message: Text("By deleting your account all your data, such as comments and highlights will be permanently deleted. Are you sure you want to proceed?".localized()),
                                primaryButton: .destructive(Text("Yes".localized())) {
                                    accountManager.removeAccount()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    
                    
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Settings".localized())
            .toolbarBackground(Color.clear, for: .navigationBar)
            .sheet(isPresented: $showAboutUs) {
                AboutView()
            }
        }
        .onAppear {
            
            let time = DateInRegion(Preferences.reminderTime(), format: "HH:mm")
            let hour = time?.hour ?? 0
            let minute = time?.minute ?? 0
            
            if let updatedDate =
                Calendar.current.date(
                    bySettingHour: hour,
                    minute: minute,
                    second: 0,
                    of: Date.now) {
                self.reminderTime = updatedDate
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

