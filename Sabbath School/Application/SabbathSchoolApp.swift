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
import CoreSpotlight

enum TabSelection: String {
    case ss
    case aij
    case devo
    case pm
    case profile
    case explore
}

let quickActionSettings = QuickActionSettings()
var shortcutItemToProcess: UIApplicationShortcutItem?

class QuickActionSettings: ObservableObject {
    enum QuickAction: Hashable {
        case home
        case details(name: String)
    }
    
    @Published var quickAction: QuickAction? = nil
}

@main
struct SabbathSchoolApp: App {
    @Environment(\.scenePhase) var phase
    @Environment(\.colorScheme) var colorScheme
    
    @UIApplicationDelegateAdaptor(AppDelegateV2.self) var appDelegate
    
    @StateObject private var accountManager = AccountManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var audioPlaybackV2 = AudioPlayback()
    
    private var screenSizeMonitor = ScreenSizeMonitor()
    private var themeManager = ThemeManager()
    
    @StateObject private var resourceInfoViewModel: ResourceInfoViewModel = ResourceInfoViewModel()
    
    @State private var selected: TabSelection = .ss

    @State private var sspath: [NavigationStep] = []
    @State private var aijpath: [NavigationStep] = []
    @State private var pmpath: [NavigationStep] = []
    @State private var devopath: [NavigationStep] = []
    @State private var explorepath: [NavigationStep] = []
    
    @State private var shortcutLaunched: String = ""
    
    init () {
        Configuration.configureFontblaster()
        Configuration.configurePreferences()
        Configuration.configurePDF()
        Configuration.configureMisc()
        Configuration.configureCache()
        Configuration.configureUI()
        Configuration.reloadAllWidgets()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let _ = accountManager.account {
                    Group {
                        if let resourceInfo = resourceInfoViewModel.resourceInfoForLanguage {
                            if resourceInfo.aij || resourceInfo.pm || resourceInfo.devo || resourceInfo.explore {
                                TabView(selection: $selected) {
                                    Group {
                                        ResourceFeedView(resourceType: .ss, path: $sspath)
                                            .tag(TabSelection.ss)
                                            .tabItem {
                                                VStack {
                                                    Text("")
                                                    Image(uiImage: UIImage(named: "icon-navbar-ss")!)
                                                }
                                            }
                                        
                                        ResourceFeedView(resourceType: .aij, path: $aijpath)
                                            .tag(TabSelection.aij)
                                            .tabItem {
                                                VStack {
                                                    Text("")
                                                    Image(uiImage: UIImage(named: "icon-navbar-aij")!)
                                                }
                                            }
                                        
                                        ResourceFeedView(resourceType: .pm, path: $pmpath)
                                            .tag(TabSelection.pm)
                                            .tabItem {
                                                VStack {
                                                    Text("")
                                                    Image(uiImage: UIImage(named: "icon-navbar-pm")!)
                                                }
                                            }
                                        
                                        ResourceFeedView(resourceType: .explore, path: $explorepath)
                                            .tag(TabSelection.explore)
                                            .tabItem {
                                                VStack {
                                                    Text("")
                                                    Image(uiImage: UIImage(named: "icon-navbar-explore")!)
                                                }
                                            }
                                        
                                        ResourceFeedView(resourceType: .devo, path: $devopath)
                                            .tag(TabSelection.devo)
                                            .tabItem {
                                                VStack {
                                                    Text("")
                                                    Image(uiImage: UIImage(named: "icon-navbar-devo")!)
                                                }
                                            }
                                    }
                                }
                                .onAppear {
                                    let appearance = UITabBarAppearance()
                                    UITabBar.appearance().scrollEdgeAppearance = appearance
                                }
                                .accentColor(.black | .white)
                                .transition(.opacity)
                            } else {
                                ResourceFeedView(resourceType: .ss, path: $sspath)
                                    .transition(.opacity)
                                    .accentColor(.black | .white)
                        }
                    } else {
                            ProgressView()
                        }
                    }
                    .task {
                        await resourceInfoViewModel.retrieveResourceInfo()
                    }
                    .onChange(of: selected) { _ in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .id(shortcutLaunched)
                } else {
                    LoginView(accountManager: accountManager)
                        .transition(.opacity)
                }
            }
            .id(languageManager.language?.code ?? "en")
            .environmentObject(accountManager)
            .environmentObject(languageManager)
            .environmentObject(screenSizeMonitor)
            .environmentObject(themeManager)
            .environmentObject(audioPlaybackV2)
            .animation(.easeInOut(duration: 0.5), value: accountManager.account != nil)
            .onOpenURL { url in
                handleUrl(url)
            }
            .onChange(of: phase) { (newPhase) in
                switch newPhase {
                case .active:
                    guard let index = shortcutItemToProcess?.userInfo?["index"] as? String else {
                        return
                    }
                    
                    let newShortcut = "\(Constants.API.HOST)/\(index)"
                    handleUrl(URL(string: newShortcut)!)
                default:
                    break
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadItem)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                screenSizeMonitor.updateAppSize()
            }
        }
    }
    
    func loadItem(_ userActivity: NSUserActivity) {
        if let index = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            let newShortcut = "\(Constants.API.HOST)/\(index)"
            handleUrl(URL(string: newShortcut)!)
        }
    }
    
    func handleUrl(_ url: URL) {
        if !shortcutLaunched.isEmpty && (shortcutLaunched == url.absoluteString) {
            return
        }
        
        shortcutLaunched = url.absoluteString
  
        let urlPath = url.path
        let patternLegacy = #"^/(?<language>[a-zA-Z]{2,3})(?:/(?<resourceId>[^/]+))?(?:/(?<documentId>[^/]+))?(?:/(?<segmentName>[^/]+))?$"#
        let patternResources = #"^(/resources)?/(?<language>[a-zA-Z]{2,})(?:/(?<resourceType>aij|pm|ss|devo|explore))?(?:/(?<resourceId>[^/]+))?(?:/(?<documentId>[^/]+))?(?:/(?<segmentName>[^/]+))?$"#
        var pattern = patternLegacy
        
        if let _ = url.path.range(of: "(/resources)?/(aij|ss|pm|devo|explore)", options: [.caseInsensitive, .regularExpression]) {
            pattern = patternResources
        }

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])

            let range = NSRange(urlPath.startIndex..<urlPath.endIndex, in: urlPath)
            if let match = regex.firstMatch(in: urlPath, options: [], range: range) {
                
                var resolvedPath: [NavigationStep] = []
                
                let language = match.range(withName: "language").location != NSNotFound ? String(urlPath[Range(match.range(withName: "language"), in: urlPath)!]) : nil
                let resourceType = match.range(withName: "resourceType").location != NSNotFound ? String(urlPath[Range(match.range(withName: "resourceType"), in: urlPath)!]) : "ss"
                let resourceId = match.range(withName: "resourceId").location != NSNotFound ? String(urlPath[Range(match.range(withName: "resourceId"), in: urlPath)!]) : nil
                let documentId = match.range(withName: "documentId").location != NSNotFound ? String(urlPath[Range(match.range(withName: "documentId"), in: urlPath)!]) : nil
                let segmentName = match.range(withName: "segmentName").location != NSNotFound ? String(urlPath[Range(match.range(withName: "segmentName"), in: urlPath)!]) : nil
                
                if let language = language {
                    if language != languageManager.language?.code {
                        languageManager.language = QuarterlyLanguage(code: language, name: "")
                    }
                    
                    if let resourceId = resourceId {
                        resolvedPath.append(.resource("\(language)/\(resourceType)/\(resourceId)"))
                        
                        if let documentId = documentId {
                            resolvedPath.append(.document("\(language)/\(resourceType)/\(resourceId)/\(documentId)", segmentName))
                        }
                    }
                    
                    if resolvedPath.count > 0 {
                        if resourceType == "ss" {
                            sspath = []
                            sspath = resolvedPath
                            selected = .ss
                        } else if (resourceType == "aij") {
                            aijpath = resolvedPath
                            selected = .aij
                        } else if (resourceType == "devo") {
                            devopath = resolvedPath
                            selected = .devo
                        } else if (resourceType == "pm") {
                            pmpath = resolvedPath
                            selected = .pm
                        } else if (resourceType == "explore") {
                            explorepath = resolvedPath
                            selected = .explore
                        }
                    }
                }
            }
        } catch { }
    }
}

class AppDelegateV2: NSObject, UIApplicationDelegate {
    @AppStorage("shortcutItemType") private var shortcutItemType: String?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        
        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
    }
}
