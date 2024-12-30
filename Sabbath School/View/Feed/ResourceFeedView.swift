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

enum NavigationStep: Hashable {
    case resource(String)
    case document(String, String? = nil)
}

struct ResourceFeedView: View {
    var resourceType: ResourceType
    @Binding var path: [NavigationStep]

    @StateObject var viewModel: ResourceFeedViewModel = ResourceFeedViewModel()
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    @State var showLanguage: Bool = false
    @State var showSettings: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if let feed = self.viewModel.feed {
                    ScrollView(.vertical, showsIndicators: false) {
                        // Adding VStack to prevent unnecessary spacing between elements in the ScrollView
                        VStack (spacing: 0) {
                            ForEach(feed.groups, id: \.id) { group in
                                FeedGroupView(resourceType: resourceType, feedGroup: group)
                            }
                        }
                        .frame(maxWidth: screenSizeMonitor.screenSize.width)
                    }
                    .navigationTitle(feed.title)
                    
                } else {
                    FeedLoadingView()
                }
            }
            .navigationDestination(for: NavigationStep.self) { step in
               switch step {
               case .resource(let resourceIndex):
                   ResourceView(resourceIndex: resourceIndex)
               case .document(let documentIndex, let segmentName):
                   DocumentView(documentIndex: documentIndex, segmentName: segmentName)
               }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSettings.toggle()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image(systemName: "gearshape")
                            .imageScale(.medium)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showLanguage.toggle()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image("icon-navbar-language")
                            .renderingMode(.template)
                            .foregroundColor(.black | .white)
                    }
                }
            }
            .refreshable {
                await retrieveContent()
            }
        }
        .sheet(isPresented: $showLanguage) {
            LanguageView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .task {
            await retrieveContent()
        }
        .onAppear {
            UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
        }
    }
    
    func retrieveContent() async {
        await viewModel.retrieveFeed(resourceType: self.resourceType, language: PreferencesShared.currentLanguage().code)
    }
}

struct ResourceFeedView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceFeedView(resourceType: .ss, path: .constant([])).environmentObject(ScreenSizeMonitor())
    }
}
