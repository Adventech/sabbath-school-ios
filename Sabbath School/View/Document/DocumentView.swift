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
import PSPDFKit
import PSPDFKitUI
import SwiftAudioEx
import NukeUI

struct DocumentView: View {
    var documentIndex: String
    var segmentName: String? = nil
    
    @State var showThemeAux = false
    @State var showVideoAux = false
    @State var showAudioAux = false
    
    @StateObject var resourceViewModel: ResourceViewModel = ResourceViewModel()
    @StateObject var viewModel: DocumentViewModel = DocumentViewModel()
    @StateObject var documentViewOperator: DocumentViewOperator = DocumentViewOperator()

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var ready: Bool = false
    
    enum MenuItemIdentifier: String, Hashable {
        case originalPDF
        case readingOptions
    }
    
    var menuItems: [MenuItemIdentifier] = [.originalPDF, .readingOptions]
    
    var btnBack: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName:
                    documentViewOperator.shouldShowCovers() && !documentViewOperator.shouldShowNavigationBar
                    ? "arrow.backward.circle.fill"
                    : "arrow.backward")
            .symbolRenderingMode(documentViewOperator.shouldShowCovers() && !documentViewOperator.shouldShowNavigationBar ? .multicolor : .monochrome)
            .foregroundColor(documentViewOperator.shouldShowNavigationBar
                             ? colorScheme == .dark ? .white : .black
                             : (documentViewOperator.shouldShowCovers() ? .black.opacity(0.5) : colorScheme == .dark ? .white : .black)
            )
            .aspectRatio(contentMode: .fit)
            .id(documentViewOperator.shouldShowNavigationBar)
            .transition(.opacity.animation(.easeInOut))
        }
    }

    var isActiveTabPDF: Binding<Bool> {
        Binding<Bool>(
            get: {
                if let segments = viewModel.document?.segments {
                    return segments[documentViewOperator.activeTab].type == .pdf
                }
                return false
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        Group {
            if resourceViewModel.fontsDownloaded {
                if let resource = resourceViewModel.resource,
                   let document = viewModel.document,
                   let segments = viewModel.document?.segments, ready {
                    ZStack(alignment: .bottom) {
                        ScrollView(.init()) {
                            pagerView(resource, document, segments)
                                .environment(\.dismissAction, {
                                    presentationMode.wrappedValue.dismiss()
                                })
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                miniPlayerView()
                                
                                miniHiddenSegment()
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, AppStyle.Segment.Spacing.horizontalPaddingHeader(screenSizeMonitor.screenSize.width))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, documentViewOperator.tabBarHeight)
                    }
                }
            } else {
                DocumentLoadingView()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
        .task {
            if viewModel.document != nil { return }
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            await setup()
        }
        .onChange(of: documentViewOperator.activeTab) { newValue in
            documentViewOperator.setShowTabBar(documentViewOperator.shouldShowTabBar(), tab: newValue, force: true)
            documentViewOperator.setShowNavigationBar(documentViewOperator.shouldShowNavigationBar, tab: newValue)
        }
        .onChange(of: documentViewOperator.hiddenSegmentIterator) { _ in
            if let hiddenSegmentID = documentViewOperator.hiddenSegmentID, !hiddenSegmentID.isEmpty {
                Task {
                    await viewModel.retrieveSegment(segmentIndex: hiddenSegmentID, completion: { segment in
                        documentViewOperator.hiddenSegment = segment
                    })
                }
                
                documentViewOperator.shouldShowHiddenSegment = true
            }
        }
        .sheet(isPresented: $showAudioAux) {
            AudioAuxiliaryView(
                audio: viewModel.audioAuxiliary ?? [],
                documentIndex: viewModel.document?.id ?? "",
                segmentIndex: viewModel.document?.segments?[documentViewOperator.activeTab].id ?? ""
            )
        }
        .sheet(isPresented: $showVideoAux) {
            VideoAuxiliaryView(
                videos: viewModel.videoAuxiliary ?? [],
                targetIndex: viewModel.document?.id ?? ""
            )
            .presentationDetents([.large])
        }
        .toolbar {
            toolbarView()
        }
        .environmentObject(viewModel)
        .environmentObject(resourceViewModel)
        .toolbarBackground(documentViewOperator.shouldShowNavigationBar ? .visible : .hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(documentViewOperator.navigationBarTitle)
        .toolbar {
            if let document = viewModel.document,
               let segments = document.segments,
               documentViewOperator.shouldShowNavigationBar && documentViewOperator.segmentChipsEnabled {
                ToolbarItem(placement: .principal) {
                    if documentViewOperator.segmentChipsStyle == .menu {
                        Menu {
                            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                                Button(action: {
                                    documentViewOperator.activeTab = index
                                }){
                                    Group {
                                        Text(segment.title)
                                        
                                        if let date = segment.date {
                                            Text(date.date.stringReadDate()
                                                .replacingLastOccurrence(of: Constants.StringsToBeReplaced.saturday,
                                                                         with: Constants.StringsToBeReplaced.sabbath))
                                        } else if let subtitle = segment.subtitle {
                                            Text(subtitle)
                                        }
                                    }
                                    
                                    if index == documentViewOperator.activeTab {
                                        Image(systemName: "checkmark")
                                            .tint(AppStyle.Resource.Section.Dropdown.chevronTint)
                                    }
                                }
                            }
                        } label: {
                            documentTitle
                                // for some reason iOS does not truncate the toolbar item label text, so we have to do it ourselves
                                .frame(maxWidth: screenSizeMonitor.screenSize.width*0.5)
                        }
                    } else {
                        documentTitle
                        .onTapGesture {
                            if !documentViewOperator.segmentChipsEnabled { return }
                            documentViewOperator.showSegmentChips.toggle()
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .top) {
            if documentViewOperator.showSegmentChips {
                segmentChipsView()
            }
        }
        .onChange(of: colorScheme) { newColorScheme in
            themeManager.setTheme(to: themeManager.currentTheme)
        }
        .onAppear {
            themeManager.setTheme(to: themeManager.currentTheme)
        }
        .sheet(isPresented: $documentViewOperator.shouldShowHiddenSegment) {
            ZStack(alignment: .top) {
                hiddenSegment
                
                HStack {
                    Button (action: {
                        documentViewOperator.shouldShowHiddenSegment.toggle()
                    }) {
                        Image(systemName: "chevron.down.circle.fill")
                            .renderingMode(.original)
                            .imageScale(.large)
                            .foregroundColor(.black | .secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    Spacer()
                }
                
            }
        }
    }
    
    var documentTitle: some View {
        HStack {
            Text(documentViewOperator.navigationBarTitle)
                .lineLimit(1)
                .font(.headline)
                
            
            if documentViewOperator.segmentChipsEnabled {
                Image(systemName: documentViewOperator.showSegmentChips ? "chevron.up" : "chevron.down")
                    .imageScale(.small)
                    .foregroundColor((.black | .white).opacity(0.5))
            }
        }
    }

    func setup() async {
        if viewModel.document != nil { return }
        
        if let segmentName = segmentName {
            viewModel.selectedSegmentName = segmentName
        }
        
        await viewModel.retrieveDocument(documentIndex: documentIndex, completion: {
            Task {
                if let document = viewModel.document {
                    documentViewOperator.activeTab = viewModel.selectedSegmentIndex ?? 0
                    if let segments = document.segments {
                        documentViewOperator.segmentChipsEnabled = segments.count > 1
                        documentViewOperator.segmentChipsStyle = document.segmentChipsStyle ?? documentViewOperator.segmentChipsStyle
                        
                        for (index, segment) in segments.enumerated() {
                            documentViewOperator.setShowTabBar(segment.type == .block || segment.type == .video || segment.type == .pdf, tab: index)
                            documentViewOperator.navigationBarTitles[index] = segment.title
                            documentViewOperator.setShowCovers(segment.type == .block && ((document.cover != nil) || (segment.cover != nil)), tab: index)
                            documentViewOperator.setShowNavigationBar(segment.type == .pdf || segment.type == .video, tab: index)
                        }
                        ready = true
                    }
                    await resourceViewModel.downloadFonts(resourceIndex: document.resourceIndex)
                    Configuration.configureFontblaster()
                    
                    await resourceViewModel.saveProgress(documentId: document.id)
                    await viewModel.retrieveDocumentUserInput(documentId: document.id)
                    await viewModel.retrievePDFAux(resourceIndex: document.resourceIndex, documentIndex: document.index)
                    await viewModel.retrieveVideoAux(resourceIndex: document.resourceIndex, documentIndex: document.index)
                    await viewModel.retrieveAudioAux(resourceIndex: document.resourceIndex, documentIndex: document.id)
                }
            }
        })
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(documentIndex: "en/devo/test/blocks").environmentObject(ScreenSizeMonitor())
    }
}
