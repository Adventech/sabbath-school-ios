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
    @EnvironmentObject var downloadManager: DownloadManager
    
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
               .if (!showNavigationBar) { view in
                   view.resizable().frame(width: 30, height: 30)
               }
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
    
    private var downloadDisabled: Bool {
        return viewModel.resource?.downloadable == false
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
                                    
                                    HStack {
                                        if resource.cta?.hidden != true {
                                            ctaButton(resource: resource)
                                        }
                                        
                                        if let share = resource.share, share.shareCTA == true {
                                            shareButton(resource: resource, shareOptions: share, cta: true)
                                        }
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
                            
                            if (resource.features.count > 0 || resource.credits.count > 0) {
                                VStack (spacing: 20) {
                                    if resource.features.count > 0 {
                                        ResourceFeaturesView(features: resource.features)
                                    }
                                    
                                    if resource.credits.count > 0 {
                                        ResourceCreditsView(credits: resource.credits)
                                    }
                                }
                                .padding(AppStyle.Resource.Spacing.paddingForFooter)
                                .background(AppStyle.Resource.Footer.color)
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
                    .navigationTitle(showNavigationBar ? resource.title : "")
                    .onChange(of: scrollOffset) { newValue in
                        showNavigationBar = scrollOffset <= 100
                    }
                    .coordinateSpace(name: CoordinateSpaces.scrollView)
                    .edgesIgnoringSafeArea(.top)
                    .onAppear {
                        UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
                    }
                }.toolbar {
                    toolbarView(resource: resource)
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
        HStack (spacing: 0) {
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
                .padding(.leading, AppStyle.Resource.ReadButton.horizontalPadding)
                .padding(.trailing, downloadDisabled ? AppStyle.Resource.ReadButton.horizontalPadding : 20)
                .padding(.vertical, AppStyle.Resource.ReadButton.verticalPadding)
            }
            
            Divider()
                .overlay(Color(hex: resource.primaryColor))
            
            if !downloadDisabled {
                downloadButton(resource: resource)
                    .padding(.vertical, AppStyle.Resource.ReadButton.verticalPadding)
                    .padding(.horizontal, 10)
            }
        }
        
        .shadow(radius: AppStyle.Resource.ReadButton.shadowRadius)
        .layoutPriority(3)
        .buttonStyle(.plain)
        .background(Color(hex: resource.primaryColorDark))
        .clipShape(
            RoundedCorner(radius: 25, corners: [.allCorners])
        )
        .frame(maxHeight: 40)
    }
    
    @ViewBuilder
    func downloadButton(resource: Resource) -> some View {
        Button {
            guard let item = downloadManager.downloadItems[resource.id] else {
                downloadManager.download(resourceId: resource.id, resourceIndex: resource.index)
                return
            }

            switch item.getStatus() {
            case .downloading:
                // Do nothing or show cancel option
                break
            default:
                if item.isCompleted() {
                    // Handle completed action (e.g., remove)
                } else {
                    downloadManager.download(resourceId: resource.id, resourceIndex: resource.index)
                }
            }
        } label: {
            Group {
                let item = downloadManager.downloadItems[resource.id]
                let status = item?.getStatus()
                let isCompleted = item?.isCompleted() ?? false

                ZStack {
                    Image(systemName: "cloud.fill")
                        .foregroundColor(.white)

                    Group {
                        if status == .downloading {
                            SpinningIcon(foregroundColor: Color(hex: resource.primaryColorDark))
                        } else if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .semibold))
                                .foregroundColor(Color(hex: resource.primaryColorDark))
                        } else {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(Color(hex: resource.primaryColorDark))
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 2), value: status)
                }
                .frame(maxWidth: 15)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
        .background(.clear)
        .clipShape(
            RoundedCorner(radius: 25, corners: [.topRight, .bottomRight])
        ).contextMenu {
            let item = downloadManager.downloadItems[resource.id]
            if item == nil || (item?.isCompleted() == false && item?.getStatus() == .idle) {
                Group {
                    Button(action: {
                        downloadManager.download(resourceId: resource.id, resourceIndex: resource.index)
                    }) {
                        Text("Download".localized())
                        Image(systemName: "arrow.down.circle")
                    }
                }
            } else if item != nil && (item?.isCompleted() == true && item?.getStatus() == .idle) {
                Group {
                    Button(action: {
                        downloadManager.download(resourceId: resource.id, resourceIndex: resource.index)
                    }) {
                        Text("Download again".localized())
                        Image(systemName: "arrow.down.circle")
                    }
                    
                    Button(role: .destructive, action: {
                        downloadManager.removeDownload(resourceId: resource.id, resourceIndex: resource.index)
                    }) {
                        Text("Remove download".localized())
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    func toolbarView(resource: Resource) -> some ToolbarContent {
        if let shareOptions = resource.share, !(shareOptions.shareCTA == true) || showNavigationBar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton(resource: resource, shareOptions: shareOptions)
            }
        }
    }
    
    @ViewBuilder
    func shareButton(resource: Resource, shareOptions: ShareOptions, cta: Bool = false) -> some View {
        // TODO: when personalization implemented add as a check:
        // resource.share?.personalize != true,
        if resource.share?.shareGroups.count == 1,
           resource.share?.shareGroups.first?.type == .link,
           let shareLink = resource.share?.shareGroups.first?.asType(ShareGroupLink.self),
           shareLink.links.count == 1,
           let shareURL = shareLink.links.first?.src
        {
            ShareLink(item: shareURL){
                Image(systemName:
                        cta || !showNavigationBar ? "square.and.arrow.up.circle.fill" : "square.and.arrow.up"
                    )
                    .renderingMode(.original)
                    .if (!cta && !showNavigationBar) { view in
                        view.resizable().frame(width: 30, height: 30)
                    }
                    .if (cta) { view in
                        view.font(.title)
                    }
                    .fontWeight(.medium)
                    .foregroundColor(showNavigationBar ? colorScheme == .dark ? .white : .black : Color(hex: resource.primaryColorDark))
                    .aspectRatio(contentMode: .fit)
                    .id(showNavigationBar)
                    .transition(.opacity.animation(.easeInOut))
            }
            .buttonStyle(.plain)
        } else {
            Button {
                let shareManager = ShareDialogManager(shareOptions: shareOptions)
                shareManager.showShareDialog(resource: resource)
            } label: {
                Image(systemName:
                        cta || !showNavigationBar ? "square.and.arrow.up.circle.fill" : "square.and.arrow.up"
                    )
                    .renderingMode(.original)
                    
                    .if (!cta && !showNavigationBar) { view in
                        view.resizable().frame(width: 30, height: 30)
                    }
                    .if (cta) { view in
                        view.font(.title)
                    }
                    .fontWeight(.medium)
                    .foregroundColor(showNavigationBar ? colorScheme == .dark ? .white : .black : Color(hex: resource.primaryColorDark))
                    .aspectRatio(contentMode: .fit)
                    .id(showNavigationBar)
                    .transition(.opacity.animation(.easeInOut))
            }
            .buttonStyle(.plain)
        }
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

struct SpinningIcon: View {
    @State var foregroundColor: Color = .black
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
            .font(.system(size: 7, weight: .semibold))
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0), anchor: .center)
            .animation(
                .linear(duration: 1.0).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
            .foregroundColor(foregroundColor)
    }
}

struct ResourceView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceView(resourceIndex: "en/devo/test").environmentObject(ScreenSizeMonitor())
    }
}

