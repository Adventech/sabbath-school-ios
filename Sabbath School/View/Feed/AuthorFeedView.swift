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
import NukeUI

struct AuthorFeedView: View {
    var authorId: String
    @State private var showNavigationBar: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @StateObject var viewModel: AuthorFeedViewModel = AuthorFeedViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    var btnBack: some View {Button(action: {
        self.presentationMode.wrappedValue.dismiss()
       }) {
            if #available(iOS 26.0, *) {
                Image(systemName: "chevron.backward")
                    .imageScale(.medium)
            } else {
                Image(systemName: showNavigationBar ? "arrow.backward" : "arrow.backward.circle.fill")
                    .renderingMode(.original)
                    .foregroundColor(showNavigationBar ? (colorScheme == .dark ? .white : .black) : Color(hex: viewModel.author?.primaryColorDark ?? "#000000"))
                    .aspectRatio(contentMode: .fit)
                    .id(showNavigationBar)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }

    private enum CoordinateSpaces {
        case scrollView
    }
    
    var body: some View {
        VStack {
            if let author = self.viewModel.author {
                ScrollViewReader { scroll in
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack (alignment: .bottom) {
                            ParallaxHeader(
                                coordinateSpace: CoordinateSpaces.scrollView,
                                defaultHeight: author.covers.splash == nil ? 0 : AppStyle.Author.Splash.height
                            ) {
                                if let splash = author.covers.splash {
                                    LazyImage(url: splash) { state in
                                        if let image = state.image {
                                            image.resizable()
                                                .scaledToFill()
                                        }
                                    }
                                } else {
                                    Color(hex: author.primaryColor).edgesIgnoringSafeArea(.top)
                                }
                            }
                            
                            VStack(spacing: 20) {
                                if let logo = author.logo {
                                    LazyImage(url: logo) { state in
                                        if let image = state.image {
                                            image.resizable()
                                                .scaledToFit()
                                        }
                                    }.frame(maxHeight: 60)
                                } else {
                                    Text(author.title)
                                        .font(.custom("Lato-Black", size: 28))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                }
                                
                                if let subtitle = author.subtitle {
                                    Text(subtitle)
                                        .font(.custom("Lato-Regular", size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(2)
                                }
                            }
                            .padding(.top, 150)
                            .padding(.bottom, 40)
                        }
                        .edgesIgnoringSafeArea(.top)
                        
                        // Adding VStack to prevent unnecessary spacing between elements in the ScrollView
                        VStack (alignment: .leading, spacing: 0) {
                            ForEach(author.feed.groups, id: \.id) { group in
                                FeedGroupView(resourceType: .authors, feedGroup: group, prefix: author.id)
                            }
                            
                            if let details = author.details {
                                VStack (alignment: .leading, spacing: 10) {
                                    ForEach(Array(details.enumerated()), id: \.offset) { index, detail in
                                        Text(detail.title)
                                            .font(.custom("Lato-Bold", size: 18))
                                            .foregroundColor(.black | .white)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .textSelection(.enabled)
                                        
                                        ForEach(Array(detail.content.splitByNewLine().enumerated()), id: \.offset) { contentIndex, content in
                                            Text(try! AttributedString(styledMarkdown: content))
                                                .font(.custom("Lato-Regular", size: 16))
                                                .foregroundColor(.black | .white)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .textSelection(.enabled)
                                        }
                                    }
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if let links = author.links {
                                VStack (alignment: .leading, spacing: 10) {
                                    ForEach(Array(links.enumerated()), id: \.offset) { index, link in
                                        Divider()
                                        
                                        Link(destination: link.url) {
                                            HStack {
                                                Text(link.title)
                                                    .font(.custom("Lato-Regular", size: 16))
                                                    .foregroundColor(.baseBlue | .white)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "arrow.up.forward.square")
                                                    .font(.system(size: 16, weight: .light))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                    }
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .background(AppStyle.Base.backgroundColor)
                        .offset(y: -10)
                        .frame(width: screenSizeMonitor.screenSize.width)
                        .background(GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                scrollOffset = geometry.frame(in: .named(CoordinateSpaces.scrollView)).minY
                            }
                            return Color.clear
                        })
                    }
                    .navigationTitle(showNavigationBar ? author.title : "")
                    .onChange(of: scrollOffset) { newValue in
                        showNavigationBar = scrollOffset <= 100
                    }
                    .coordinateSpace(name: CoordinateSpaces.scrollView)
                    .edgesIgnoringSafeArea(.top)
                    .onAppear {
                        UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
                    }
                }
            } else {
                FeedLoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                btnBack
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(showNavigationBar ? .visible : .hidden, for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .dark : (showNavigationBar ? .light : .dark), for: .navigationBar)
        .task {
            await retrieveContent()
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func retrieveContent() async {
        await viewModel.retrieveAuthor(authorId: self.authorId, language: PreferencesShared.currentLanguage().code)
    }
}
