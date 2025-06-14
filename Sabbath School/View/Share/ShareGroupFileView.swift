/*
 * Copyright (c) 2025 Adventech <info@adventech.io>
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
import LinkPresentation

struct ShareGroupFileView: View {
    @State var fileName: String
    @State var shareText: String
    @State var featuredColor: Color
    @State var shareGroup: ShareGroupFile
    @State var selectedFile = 0
    @State var downloading: Bool = false
    @State private var downloadedFileURL: URL?
    
    var showDropdown: Bool {
        guard let _ = shareGroup.files[selectedFile].title,
              shareGroup.files.count > 1 else { return false }
        return true
    }
    
    @ViewBuilder
    var dropdown: some View {
        if let title = shareGroup.files[selectedFile].title, showDropdown {
            Menu {
                ForEach(Array(shareGroup.files.enumerated()), id: \.offset) { index, file in
                    Button(action: {
                        selectedFile = index
                    }) {
                        HStack {
                            Text(file.title ?? "")
                            
                            Spacer()
                            
                            if index == selectedFile {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(title)
                    .font(.custom("Lato-Medium", size: 18))
                    .foregroundColor(.black | .white)
                
                Image(systemName: "triangle.fill")
                    .rotationEffect(.degrees(180))
                    .font(.system(size: 8))
                    .foregroundColor(.black | .white)
            }.frame(maxWidth: 100)
            
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack (spacing: 20) {
            if showDropdown {
                dropdown
            }
            
            if let fileURL = downloadedFileURL {
                ShareLink(item: fileURL) {
                    ShareLabel(shareText: shareText, featuredColor: featuredColor)
                }.id(selectedFile)
            } else {
                if downloading {
                    ProgressView()
                        .padding(10)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                        .padding(10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            Task {
                await initializeDownload()
            }
        }
        .onChange(of: selectedFile) { newValue in
            Task {
                await initializeDownload()
            }
        }
    }
    
    func initializeDownload() async {
        if let targetFileURL = shareGroup.files[safe: selectedFile]?.src {
            let fileExt = targetFileURL.pathExtension.count > 1 ? ".\(targetFileURL.pathExtension)" : ""
            let finalFilename = "\(shareGroup.files[safe: selectedFile]?.fileName ?? fileName)\(fileExt)"
            self.downloading = true
            do {
                self.downloadedFileURL = try await Downloader.download(remoteURL: targetFileURL, destinationFileURL: Helper.ShareFileURL(fileName: finalFilename))
                self.downloading = false
            } catch {
                self.downloadedFileURL = nil
                self.downloading = false
            }
        }
    }
}
