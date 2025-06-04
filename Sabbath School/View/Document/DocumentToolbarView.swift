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

extension DocumentView {
    @ToolbarContentBuilder
    func toolbarView() -> some ToolbarContent {
        if let segment = viewModel.document?.segments?[documentViewOperator.activeTab],
           (segment.type == .block || segment.type == .pdf || segment.type == .video || (segment.type == .story) && documentViewOperator.shouldShowNavigationBar) {
            Group {
                if let audio = viewModel.audioAuxiliary, audio.count > 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAudioAux = true
                        } label: {
                            Image(systemName: "headphones")
                                .renderingMode(.original)
                                .foregroundColor(resolvedForegroundColor())
                                .aspectRatio(contentMode: .fit)
                                .imageScale(.medium)
                        }
                    }
                }
                
                if viewModel.videoAuxiliary != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showVideoAux = true
                        } label: {
                            Image(systemName: "play.tv")
                                .renderingMode(.original)
                                .foregroundColor(resolvedForegroundColor())
                                .aspectRatio(contentMode: .fit)
                                .imageScale(.medium)
                        }
                    }
                }
            }
        }
        
        if let segment = viewModel.document?.segments?[documentViewOperator.activeTab],
           segment.type == .block || segment.type == .video {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(menuItems, id:\.self) { menuItem in
                        switch menuItem {
                        case .originalPDF:
                            if let pdfAuxiliary = viewModel.pdfAuxiliary,
                               pdfAuxiliary.count > 0 {
                                NavigationLink {
                                    PDFAuxiliaryView(pdfs: viewModel.pdfAuxiliary ?? [])
                                        .environmentObject(viewModel)
                                } label: {
                                    HStack {
                                        Text("Original PDF".localized())
                                        Image(systemName: "doc.text")
                                    }
                                }
                            }
                            
                        case .readingOptions:
                            Button(action: {
                                self.showThemeAux = true
                            }) {
                                HStack {
                                    Text("Reading Options".localized())
                                    Image(systemName: "textformat")
                                }
                            }
                        }
                    }
                } label : {
                    Image(systemName: "ellipsis")
                        .renderingMode(.original)
                        .foregroundColor(resolvedForegroundColor())
                        .aspectRatio(contentMode: .fit)
                        .id(documentViewOperator.shouldShowNavigationBar)
                        .transition(.opacity.animation(.easeInOut))
                }.alwaysPopover(isPresented: $showThemeAux) {
                    ThemeAuxiliaryView().environmentObject(themeManager)
                }
            }
        }
    }
    
    private func resolvedForegroundColor() -> Color {
        documentViewOperator.shouldShowNavigationBar
            ? themeManager.getToolbarColor()
            : (documentViewOperator.shouldShowCovers()
               ? .white
               : themeManager.getTextColor())
    }

}
