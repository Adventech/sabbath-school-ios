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
import Combine

private enum CoordinateSpaces {
    case scrollView
}

final class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellables: [AnyCancellable] = []

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

        willShow
            .merge(with: willHide)
            .sink { [weak self] notification in
                self?.handleKeyboardNotification(notification)
            }
            .store(in: &cancellables)
    }

    private func handleKeyboardNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let keyboardVisible = notification.name == UIResponder.keyboardWillShowNotification
        keyboardHeight = keyboardVisible ? endFrame.height : 0
    }
}

struct SegmentViewBlocks: View {
    var segment: Segment
    var isHiddenSegment: Bool = false
    var progressTrackingTitle: String?
    var progressTrackingSubtitle: String?
    var progressNextSegmentIteratorIndex: Int?
    var scrollViewProxy: ScrollViewProxy?
    
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    var body: some View {
        if let blocks = segment.blocks {
            VStack (spacing: AppStyle.Segment.Spacing.betweenBlocks)  {
                ForEach(blocks) { block in
                    BlockWrapperView(block: block, scrollViewProxy: scrollViewProxy)
                        .environment(\.themeManager, themeManager)
                        .environment(\.defaultBlockStyles, defaultStyles)
                        .id(block.id)
                        .if(block.nested != true) { view in
                            view.background(GeometryReader { geo in
                                Color.clear.preference(key: VisibleBlockPreferenceKey.self, value: [block.id: geo.frame(in: .global).minY])
                            })
                        }
                }
                
                if let progressTrackingTitle = progressTrackingTitle,
                   !isHiddenSegment {
                    ProgressSaveButton(
                        progressTrackingTitle: progressTrackingTitle,
                        progressTrackingSubtitle: progressTrackingSubtitle,
                        progressNextSegmentIteratorIndex: progressNextSegmentIteratorIndex
                    )
                }
            }
            .padding(.bottom, keyboardResponder.keyboardHeight > 0 ? keyboardResponder.keyboardHeight : AppStyle.Segment.Spacing.verticalPaddingContent +
                     (audioPlayback.shouldShowMiniPlayer() || documentViewOperator.hiddenSegment != nil && !isHiddenSegment ? 80 * 2 : isHiddenSegment ? 0 : 80)
            )
            .padding(.top, AppStyle.Segment.Spacing.verticalPaddingContent)
            .padding(.horizontal, AppStyle.Segment.Spacing.horizontalPaddingContent(screenSizeMonitor.screenSize.width, isHiddenSegment))
        }
    }
}

struct BottomClipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: rect.minX, y: rect.minY - 1000, width: rect.width, height: rect.height + 1000))
        return path
    }
}

struct SegmentViewCover: View {
    var segment: Segment
    var document: ResourceDocument
    var resource: Resource
    var isHiddenSegment: Bool = false
    
    private var hasCover: Bool {
        return segment.type == .block && (segment.cover != nil || document.cover != nil)
    }
    
    private var titleBelowCover: Bool {
        return (document.titleBelowCover != nil && document.titleBelowCover == true)
        || (segment.titleBelowCover != nil && segment.titleBelowCover == true)
    }
    
    private var style: Style? {
        return segment.style ?? document.style ?? resource.style
    }
    
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    
    var body: some View {
        if let cover = segment.cover ?? document.cover, hasCover {
            ZStack (alignment: .bottom) {
                ParallaxHeader(
                    coordinateSpace: CoordinateSpaces.scrollView,
                    defaultHeight: AppStyle.Segment.Cover.height()
                ) {
                    LazyImage(url: cover) { image in
                        image.image?.resizable().scaledToFill()
                    }
                }
                .clipShape(BottomClipShape())
                .id(segment.index)
                
                if !titleBelowCover {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .black.opacity(0.15), location: 0.4),
                            .init(color: .black.opacity(0.3), location: 0.7),
                            .init(color: .black.opacity(0.4), location: 1.0),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ).frame(height: AppStyle.Segment.Cover.height()/2.5)
                    
                    SegmentHeader(segment.markdownTitle ?? segment.title,
                                  segment.date,
                                  segment.markdownSubtitle ?? segment.subtitle,
                                  hasCover && !titleBelowCover,
                                  segment.style ?? resource.style,
                                  AppStyle.Segment.Spacing.verticalPaddingHeader(),
                                  isHiddenSegment)
                }
            }
            .frame(height: AppStyle.Segment.Cover.height())   
        }
        
        VStack {
            if !hasCover || titleBelowCover {
                SegmentHeader(segment.markdownTitle ?? segment.title,
                              segment.date,
                              segment.markdownSubtitle ?? segment.subtitle,
                              hasCover && !titleBelowCover,
                              segment.style ?? resource.style,
                              AppStyle.Segment.Spacing.verticalPaddingHeader(),
                              isHiddenSegment)
                .padding(.top, hasCover || (hasCover && titleBelowCover) ? 20 : AppStyle.Segment.Cover.height(false))
            }
        }
    }
}

struct SegmentHeader: View {
    var title: String
    var date: ServerDate?
    var subtitle: String?
    var hasCover: Bool
    var style: Style?
    var verticalPadding: CGFloat
    var isHiddenSegment: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    init (_ title: String, _ date: ServerDate?, _ subtitle: String?, _ hasCover: Bool, _ style: Style?, _ verticalPadding: CGFloat = AppStyle.Segment.Spacing.verticalPaddingHeader(), _ isHiddenSegment: Bool = false) {
        self.title = title
        self.date = date
        self.subtitle = subtitle
        self.hasCover = hasCover
        self.style = style
        self.verticalPadding = verticalPadding
        self.isHiddenSegment = isHiddenSegment
    }
    
    var body: some View {
        VStack (spacing: AppStyle.Segment.Spacing.betweenTitleDateAndSubtitle) {
            if let subtitle = subtitle {
                VStack (spacing: 0) {
                    Text(AppStyle.Segment.Subtitle.text(subtitle, hasCover, style))
                        .multilineTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate()))
                        .lineLimit(AppStyle.Segment.Subtitle.lineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate())))
            }
            
            if let date = date {
                VStack (spacing: 0) {
                    Text(AppStyle.Segment.Date.text(
                        date.date.stringReadDate()
                            .replacingLastOccurrence(of: Constants.StringsToBeReplaced.saturday,
                                                     with: Constants.StringsToBeReplaced.sabbath),
                        hasCover, style)
                    )
                    .multilineTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate()))
                    .lineLimit(AppStyle.Segment.Date.lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate())))
            }
            
            VStack {
                Text(AppStyle.Segment.Title.text(title, hasCover, style))
                    .multilineTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate()))
                    .lineLimit(hasCover ? AppStyle.Segment.Title.lineLimit : nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate())))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppStyle.Segment.Spacing.horizontalPaddingHeader(screenSizeMonitor.screenSize.width, isHiddenSegment))
        .padding(.vertical, verticalPadding)
    }
}

struct VisibleBlockPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

class SegmentSavedScrollPosition: ObservableObject {
    @Published var visibleBlockID: String?
    @Published var scrollOffset: CGFloat = -1
    @Published var frameHeight: CGFloat = -1
    @Published var cachedScrollOffset: SavedScrollOffset?
    @Published var alreadyScrolled: Bool = false
    
    @MainActor func retrieveSavedScrollPosition(segmentId: String, completion: ((_ cachedScrollOffset: SavedScrollOffset?) -> Void)? = nil) {
        if (try? DocumentViewModel.lastVisibleScrollOffset?.existsObject(forKey: segmentId)) != nil {
            if let cachedScrollOffset = try? DocumentViewModel.lastVisibleScrollOffset?.entry(forKey: segmentId) {
                completion?(cachedScrollOffset.object)
            } else {
                completion?(nil)
            }
        } else {
            completion?(nil)
        }
    }
}

struct SegmentViewBase<Content: View>: View {
    var resource: Resource
    var segment: Segment
    var index: Int
    var document: ResourceDocument
    var isHiddenSegment: Bool = false
    var progressTrackingTitle: String?
    var progressTrackingSubtitle: String?
    var progressNextSegmentIteratorIndex: Int?
    
    let content: (SegmentViewCover, SegmentViewBlocks, SegmentViewVideo<SegmentHeader>, SegmentHeader) -> Content
    
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @EnvironmentObject var viewModel: DocumentViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    
    @StateObject var savedScrollPosition: SegmentSavedScrollPosition = SegmentSavedScrollPosition()
    @State var heightTimeout: Bool = true
    
    private var hasCover: Bool {
        return segment.type == .block && (segment.cover != nil || document.cover != nil)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView (.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    content(
                        SegmentViewCover(segment: segment, document: document, resource: resource),
                        SegmentViewBlocks(
                            segment: segment,
                            isHiddenSegment: isHiddenSegment,
                            progressTrackingTitle: progressTrackingTitle,
                            progressTrackingSubtitle: progressTrackingSubtitle,
                            progressNextSegmentIteratorIndex: progressNextSegmentIteratorIndex,
                            scrollViewProxy: proxy
                        ),
                        SegmentViewVideo(video: segment.video) {
                            SegmentHeader(segment.markdownTitle ?? segment.title,
                                          segment.date,
                                          segment.markdownSubtitle ?? segment.subtitle,
                                          false,
                                          segment.style ?? resource.style,
                                          0,
                                          isHiddenSegment)
                        },
                        SegmentHeader(segment.markdownTitle ?? segment.title,
                                      segment.date,
                                      segment.markdownSubtitle ?? segment.subtitle,
                                      false,
                                      segment.style ?? resource.style,
                                      0,
                                      isHiddenSegment)
                    )
                }
                
                .onChange(of: sizeCategory) { newValue in }
                .background{
                    if !isHiddenSegment {
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .global)) { frame in
                                let scrollOffset = frame.minY
                                let height = frame.size.height
                                
                                if index == documentViewOperator.activeTab || (index == -1 && isHiddenSegment), segment.type != .video {
                                    if height != savedScrollPosition.frameHeight, abs(height - savedScrollPosition.frameHeight) > 50, heightTimeout {
                                        scrollToLastSavedPosition(proxy: proxy)
                                        savedScrollPosition.frameHeight = height
                                    }
                                    savedScrollPosition.scrollOffset = scrollOffset
                                    updateNavigationBar(scrollOffset)
                                }
                            }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onPreferenceChange(VisibleBlockPreferenceKey.self) { values in
                updateVisibleBlock(values: values)
            }
            .background {
                if let background = segment.background ?? document.background,
                   themeManager.currentTheme == .light || (
                    colorScheme == .light && themeManager.currentTheme == .auto
                   )
                {
                    AsyncImage(url: background) { image in
                        image.image?
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .background(themeManager.backgroundColor)
            .clipped()
            .id(segment.id)
            .onAppear {
                if !savedScrollPosition.alreadyScrolled {
                    savedScrollPosition.retrieveSavedScrollPosition(segmentId: segment.id) { cachedScrollOffset in
                        savedScrollPosition.cachedScrollOffset = cachedScrollOffset
                        scrollToLastSavedPosition(proxy: proxy)
                    }
                }
                
                if heightTimeout {
                    // Giving 2 seconds timeout to scroll to the last saved position if height changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.heightTimeout = false
                    }
                }
            }.onDisappear {
                if !isHiddenSegment {
                    saveScrollPosition()
                }
            }.onChange(of: documentViewOperator.shouldShowHiddenSegment) { newValue in
                if isHiddenSegment && !newValue {
                    saveScrollPosition()
                }
            }
        }
    }
    
    func scrollToLastSavedPosition(proxy: ScrollViewProxy) {
        if let cachedScrollOffset = savedScrollPosition.cachedScrollOffset {
            updateNavigationBar(cachedScrollOffset.scrollOffset, force: true)
            savedScrollPosition.alreadyScrolled = true
            proxy.scrollTo(cachedScrollOffset.blockId, anchor: .top)
        }
    }
    
    func saveScrollPosition() {
        if savedScrollPosition.scrollOffset == 0.0 {
            try? DocumentViewModel.lastVisibleScrollOffset?.removeObject(forKey: segment.id)
        } else if let visibleBlockID = savedScrollPosition.visibleBlockID {
            try? DocumentViewModel.lastVisibleScrollOffset?.setObject(SavedScrollOffset(blockId: visibleBlockID, scrollOffset: savedScrollPosition.scrollOffset), forKey: segment.id)
        }
    }
    
    func updateNavigationBar(_ scrollOffset: CGFloat, force: Bool = false) {
        let multiplier = screenSizeMonitor.screenSize.height * AppStyle.Segment.Cover.percentageOfScreen(hasCover)
        let visibility = scrollOffset <= -1 * (multiplier - documentViewOperator.topSafeAreaInset - documentViewOperator.navigationBarHeight - documentViewOperator.chipsBarHeight)
        if visibility != documentViewOperator.shouldShowNavigationBar {
            
            if force {
                documentViewOperator.setShowNavigationBar(visibility, tab: index)
            } else {
                documentViewOperator.setShowNavigationBar(visibility)
            }
        }
    }
    
    func updateVisibleBlock(values: [String: CGFloat]) {
        if savedScrollPosition.scrollOffset == 0 || savedScrollPosition.scrollOffset == -1 { return }
        
        let sortedVisibleComponents = values.sorted(by: { abs($0.value) < abs($1.value) })
        
        if let closestComponent = sortedVisibleComponents.first {
            savedScrollPosition.visibleBlockID = closestComponent.key
        }
    }
}
