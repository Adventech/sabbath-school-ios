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
import UIKit
import NukeUI

@ViewBuilder
func AdaptiveStack<Content: View>(alignment: Alignment, spacing: CGFloat, isPad: Bool, @ViewBuilder content: () -> Content) -> some View {
    if isPad {
        HStack(spacing: spacing, content: content)
    } else {
        VStack(spacing: spacing, content: content)
    }
}

struct ResourceView: View {
    @StateObject var viewModel: ResourceViewModel = ResourceViewModel()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showNavigationBar: Bool = false
    @State private var showIntroduction: Bool = false
    
    @State private var uiImage: UIImage?
    
    var resourceIndex: String
    
    private let year = Calendar.current.component(.year, from: Date())

    var btnBack: some View {Button(action: {
        self.presentationMode.wrappedValue.dismiss()
       }) {
           Image(systemName: showNavigationBar ? "arrow.backward" : "arrow.backward.circle.fill")
               .renderingMode(.original)
               .foregroundColor(showNavigationBar ? colorScheme == .dark ? .white : .black : Color(hex: viewModel.resource?.primaryColorDark ?? "#000000"))
               .aspectRatio(contentMode: .fit)
               .id(showNavigationBar)
               .transition(.opacity.animation(.easeInOut))
       }
    }
    
    private enum CoordinateSpaces {
        case scrollView
    }
    
    private var headerFrameWidth: CGFloat {
        AppStyle.Resource.Header.frameWidth(viewModel.resource?.covers.splash == nil, screenSizeMonitor.screenSize.width)
    }
    
    private var headerFrameAlignment: Alignment {
        return AppStyle.Resource.Header.frameAlignment(viewModel.resource?.covers.splash == nil)
    }
    
    private var headerTextAlignment: TextAlignment {
        AppStyle.Resource.Header.textAlignment(viewModel.resource?.covers.splash == nil)
    }
    
    private var preferredCover: (url: URL?, size: ResourceCoverType?) {
        if let resource = viewModel.resource, let preferredCover = resource.preferredCover {
            var nonSplashCover: URL = resource.covers.portrait
            var nonSplashSize: ResourceCoverType = ResourceCoverType.portrait
            
            switch preferredCover {
            case .landscape:
                nonSplashCover = resource.covers.landscape
                nonSplashSize = .landscape
            case .square:
                nonSplashCover = resource.covers.square
                nonSplashSize = .square
            default:
                break
            }
            
            return (url: nonSplashCover, size: nonSplashSize)
        }
        return (url: nil, size: nil)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let resource = self.viewModel.resource {
                ScrollViewReader { scroll in
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack (alignment: .bottom) {
                            ParallaxHeader(
                                coordinateSpace: CoordinateSpaces.scrollView,
                                defaultHeight: resource.covers.splash == nil ? 0 : AppStyle.Resource.Splash.height
                            ) {
                                if let splash = resource.covers.splash {
                                    LazyImage(url: splash) { state in
                                        if let image = state.image {
                                            image.resizable()
                                                .scaledToFill()
                                                .onAppear {
                                                    if let container = state.imageContainer {
                                                        uiImage = container.image
                                                    }
                                                }
                                        }
                                    }
                                } else {
                                    Color(hex: resource.primaryColor).edgesIgnoringSafeArea(.top)
                                }
                            }
                            
                            if resource.covers.splash != nil {
                                GradientBlurEffectView(
                                    style: .light,
                                    width: screenSizeMonitor.screenSize.width,
                                    height: AppStyle.Resource.Splash.gradientBlurHeight
                                )
                                .frame(
                                    width: screenSizeMonitor.screenSize.width,
                                    height: AppStyle.Resource.Splash.gradientBlurHeight
                                )
                            }
                            
                            AdaptiveStack(
                                alignment: headerFrameAlignment,
                                spacing: AppStyle.Resource.Spacing.betweenTitleSubtitleReadButonDescription,
                                isPad: Helper.isPad && resource.covers.splash == nil) {
                                if resource.covers.splash == nil {
                                    LazyImage(url: preferredCover.url ?? resource.covers.portrait) { state in
                                        if let image = state.image {
                                            image.resizable()
                                                .scaledToFill()
                                                .onAppear {
                                                    if let container = state.imageContainer {
                                                        uiImage = container.image
                                                    }
                                                }
                                        }
                                    }
                                    .frame(
                                        width: AppStyle.Resource.Cover.nonSplashCover(preferredCover.size ?? .portrait).width,
                                        height: AppStyle.Resource.Cover.nonSplashCover(preferredCover.size ?? .portrait).height
                                    )
                                    .cornerRadius(6)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
                                    .padding(.top, Helper.isPad ? 0 : AppStyle.Resource.Spacing.topPaddingForNonSplashImage)
                                }
                                
                                VStack(
                                    alignment: headerFrameAlignment.horizontal,
                                    spacing: AppStyle.Resource.Spacing.betweenTitleSubtitleReadButonDescription
                                ) {
                                    Text(AppStyle.Resource.Title.text(resource.markdownTitle ?? resource.title, resource.style))
                                        .lineLimit(AppStyle.Resource.Title.lineLimit)
                                        .multilineTextAlignment(headerTextAlignment)
                                        .frame(width: headerFrameWidth, alignment: headerFrameAlignment)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .baselineOffset(-5)
                                    
                                    
                                    if let subtitle = resource.subtitle {
                                        Text(AppStyle.Resource.Subtitle.text(resource.markdownSubtitle ?? subtitle, resource.style))
                                            .lineLimit(AppStyle.Resource.Subtitle.lineLimit)
                                            .multilineTextAlignment(headerTextAlignment)
                                            .frame(width: headerFrameWidth, alignment: headerFrameAlignment)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    if resource.cta?.hidden != true {
                                        ctaButton(resource: resource)
                                    }

                                    if let description = resource.description {
                                        ZStack(alignment: .bottomTrailing) {
                                            Text(AppStyle.Resource.Description.text(resource.markdownDescription ?? description, resource.style))
                                                .lineLimit(AppStyle.Resource.Description.lineLimit)
                                                .multilineTextAlignment(.leading)
                                                .frame(width: headerFrameWidth, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .mask(
                                                    
                                                    ZStack (alignment: .bottomTrailing) {
                                                        Rectangle().fill(Color.white)
                                                        if resource.introduction != nil {
                                                            Text(AppStyle.Resource.Description.textMoreButton("\("More".localized().lowercased())\("More".localized().lowercased())"))
                                                                .background(.white)
                                                                .mask(
                                                                    LinearGradient(
                                                                        gradient: Gradient(colors: [Color.clear, Color.black, Color.black]),
                                                                        startPoint: .leading,
                                                                        endPoint: .trailing
                                                                    ))
                                                                .blendMode(.destinationOut)
                                                        }
                                                    }
                                                )
                                            
                                            if resource.introduction != nil {
                                                Button (action: {
                                                    showIntroduction = true
                                                }, label: {
                                                    Text(AppStyle.Resource.Description.textMoreButton("More".localized().lowercased(), Color(hex: resource.primaryColorDark)))
                                                        .frame(alignment: .trailing)
                                                }).buttonStyle(.plain)
                                            }
                                            
                                        }.frame(width: headerFrameWidth)
                                    }
                                    
                                    ResourceFeaturesHeaderView(features: resource.features, style: resource.style)
                                        .frame(alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, alignment: headerFrameAlignment)
                            }
                            .padding([.bottom], AppStyle.Resource.Spacing.paddingForSplashHeader)
                            .padding([.horizontal], AppStyle.Resource.Spacing.paddingForSplashHeader)
                            .padding([.top], AppStyle.Resource.Spacing.paddingForNonSplashHeader)
                            .frame(width: screenSizeMonitor.screenSize.width)
                        }
                        .edgesIgnoringSafeArea(.top)
                        
                        VStack (alignment: .leading, spacing: 0) {
                            ResourceSectionsView(resource: resource)
                                .environmentObject(viewModel)
                            
                            if let feeds = resource.feeds {
                                ForEach(feeds, id: \.id) { feed in
                                    FeedGroupView(resourceType: .pm, feedGroup: feed)
                                }
                            }
                            
                            if let authors = resource.authors {
                                VStack (spacing: 10) {
                                    ForEach(authors, id: \.id) { author in
                                        NavigationLink {
                                            AuthorFeedView(authorId: author.id)
                                        } label: {
                                            FeedResourceViewSquare(title: author.title, cover: author.covers.square, direction: .vertical, scaleFactor: 0.7)
                                        }
                                    }
                                }
                                .padding(20)
                            }
                            
                            VStack (spacing: 20) {
                                if resource.features.count > 0 {
                                    ResourceFeaturesView(features: resource.features)
                                }
                                
                                if resource.credits.count > 0 {
                                    ResourceCreditsView(credits: resource.credits)
                                }
                                
                                Text(AppStyle.Resource.Copyright.text(String(format: "© %d " + "General Conference of Seventh-day Adventists".localized() + "®", year)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                            }
                            .padding(AppStyle.Resource.Spacing.paddingForFooter)
                            .background(AppStyle.Resource.Footer.color)
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
                    .navigationTitle(showNavigationBar ? resource.title : "")
                    .onChange(of: scrollOffset) { newValue in
                        showNavigationBar = scrollOffset <= 100
                    }
                    .coordinateSpace(name: CoordinateSpaces.scrollView)
                    .edgesIgnoringSafeArea(.top)
                    .onAppear {
                        UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
                    }
                }
            }
            else {
                ResourceLoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(showNavigationBar ? .visible : .hidden, for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .dark : (showNavigationBar ? .light : .dark), for: .navigationBar)
        .background(AppStyle.Resource.Footer.color)
        .sheet(isPresented: $showIntroduction) {
            if let introduction = viewModel.resource?.introduction {
                ResourceIntroductionView(introduction: introduction)
            }
        }
        .onChange(of: uiImage) { image in
            indexResourceForSpotlight()
        }
        .onAppear {
            Task {
                await viewModel.retrieveProgress() {
                    viewModel.setReadDocumentIndex()
                }
            }
        }
        .task {
            Configuration.reloadAllWidgets()
            
            if viewModel.resource != nil { return }
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            await viewModel.downloadFonts(resourceIndex: resourceIndex)
            await viewModel.retrieveProgress() {
                viewModel.setReadDocumentIndex()
            }
            
            // shortcuts
            // TODO: remove to module
            if let resource = viewModel.resource {
                var shortcutItems = UIApplication.shared.shortcutItems ?? []
                
                let existingIndex = shortcutItems.firstIndex(where: { $0.userInfo?["index"] as? String == resource.index })
                
                if existingIndex != nil {
                    shortcutItems.remove(at: existingIndex!)
                }

                let shortcutItem = UIApplicationShortcutItem.init(
                    type: Constants.DefaultKey.shortcutItem,
                    localizedTitle: resource.title,
                    localizedSubtitle: resource.subtitle,
                    icon: .init(systemImageName: "bookmark"),
                    userInfo: ["index": resource.index as NSSecureCoding]
                )
                
                shortcutItems.insert(shortcutItem, at: 0)
                UIApplication.shared.shortcutItems = shortcutItems
            }
        }.onAppear {
            UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
        }
    }
    
    @ViewBuilder
    func ctaButton(resource: Resource) -> some View {
        NavigationLink {
            if let readButtonIndex = self.viewModel.readButtonDocumentIndex ?? self.viewModel.resource?.sections?.first?.documents.first?.index {
                DocumentView(documentIndex: readButtonIndex)
            }
        } label: {
            HStack (spacing: 5) {
                Text(AppStyle.Resource.ReadButton.text(resource.cta?.text ?? "Read".localized().uppercased()))
                    .lineLimit(AppStyle.Resource.ReadButton.lineLimit)
                    .layoutPriority(2)
                
                if let selectedDocumentTitle = viewModel.readButtonDocumentTitle,
                    let progressTracking = viewModel.resource?.progressTracking,
                   progressTracking != .none
                {
                    Text(AppStyle.Resource.ReadButton.textSelectedDocument(selectedDocumentTitle))
                        .lineLimit(1)
                        .layoutPriority(1)
                }
            }
            .padding(.vertical, AppStyle.Resource.ReadButton.verticalPadding)
            .padding(.horizontal, AppStyle.Resource.ReadButton.horizontalPadding)
            .background(Color(UIColor(hex: resource.primaryColorDark)))
            .clipShape(Capsule())
            .cornerRadius(viewModel.readButtonDocumentTitle == nil ? 0 : 10)
            .frame(maxWidth: AppStyle.Resource.ReadButton.width*1.5, alignment: headerFrameAlignment)
            .shadow(radius: AppStyle.Resource.ReadButton.shadowRadius)
            .layoutPriority(3)
            
        }
        .buttonStyle(.plain)
    }
    
    func indexResourceForSpotlight() {
        DispatchQueue.main.async {
            if let image = uiImage,
               let resource = viewModel.resource {
                Spotlight.indexResource(resource: resource, image: image)
            }
        }
        
    }
}

struct ResourceView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceView(resourceIndex: "en/devo/test").environmentObject(ScreenSizeMonitor())
    }
}

