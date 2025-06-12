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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 0) {
                    if let audio = viewModel.audioAuxiliary, audio.count > 0 {
                        Button {
                            showAudioAux = true
                        } label: {
                            Image(systemName: "headphones")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .padding(7)
                                    .foregroundColor(resolvedForegroundColor())
                        }
                    }
                    
                    if viewModel.videoAuxiliary != nil {
                        Button {
                            showVideoAux = true
                        } label: {
                            Image(systemName: "play.tv")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(4)
                                    .foregroundColor(resolvedForegroundColor())
                        }
                    }
                    
                    if segment.type == .block || segment.type == .video {
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
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17, height: 17)
                                    .padding(7)
                                    .id(documentViewOperator.shouldShowNavigationBar)
                                    .foregroundColor(resolvedForegroundColor())
                                    .transition(.opacity.animation(.easeInOut))
                        }.alwaysPopover(isPresented: $showThemeAux) {
                            ThemeAuxiliaryView().environmentObject(themeManager)
                        }
                    }
                }
                .background {
                    Rectangle().fill(.black.opacity(0.4))
                        .cornerRadius(20)
                        .if(viewModel.audioAuxiliary?.count ?? 0 > 0 || viewModel.videoAuxiliary != nil) { view in
                                view
                                    .padding([.top, .bottom], 2)
                                    .padding(.trailing, -4)
                        }
                        .if(viewModel.audioAuxiliary?.count ?? 0 <= 0 && viewModel.videoAuxiliary == nil) { view in
                                view
                                    .padding([.top, .bottom], 3)
                                    .padding([.leading], 7)
                                    .padding(.trailing, -1)
                        }
                        .opacity(!documentViewOperator.shouldShowNavigationBar && documentViewOperator.shouldShowCovers() ? 1 : 0)
                        .transition(.opacity.animation(.easeInOut))
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
