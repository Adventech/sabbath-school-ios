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

struct FeedSeeAllView: View {
    @StateObject var viewModel: ResourceFeedViewModel = ResourceFeedViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor

    var resourceType: ResourceType
    var feedGroupId: String
    var prefix: String = ""
    
    var btnBack: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
           Image(systemName: "arrow.backward")
               .renderingMode(.original)
               .foregroundColor(.black | .white)
               .aspectRatio(contentMode: .fit)
       }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let feedGroup = self.viewModel.feedGroup {
                ScrollView(.vertical, showsIndicators: false) {
                    // Adding VStack to prevent unnecessary spacing between elements in the ScrollView
                    VStack (spacing: 0) {
                        FeedGroupView(
                            resourceType: resourceType,
                            feedGroup: feedGroup,
                            displayFeedGroupTitle: false
                        )
                    }.frame(maxWidth: screenSizeMonitor.screenSize.width)
                }
                .refreshable {
                    await retrieveContent()
                }
                .navigationTitle(feedGroup.title ?? (viewModel.feed?.title ?? "test"))
            } else {
                FeedLoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await retrieveContent()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func retrieveContent() async {
        await viewModel.retrieveSeeAllFeed(
           resourceType: self.resourceType,
           feedGroupId: self.feedGroupId,
           language: PreferencesShared.currentLanguage().code,
           prefix: prefix
        )
    }
}

struct FeedSeeAllView_Previews: PreviewProvider {
    static var previews: some View {
        FeedSeeAllView(resourceType: .devo, feedGroupId: "main")
    }
}
