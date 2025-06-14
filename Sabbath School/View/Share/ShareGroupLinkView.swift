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
import CoreImage.CIFilterBuiltins

struct ShareGroupLinkView: View {
    @State var shareText: String
    @State var featuredColor: Color
    @State var shareGroup: ShareGroupLink
    @State var selectedLink = 0
    @State var showQRCode = false
    @State var isSharingQRCode = false
    
    var qrCodeImage: UIImage {
        return generateQRCode(from: shareGroup.links[selectedLink].src.absoluteString) ?? UIImage()
    }
    
    var showDropdown: Bool {
        guard let _ = shareGroup.links[selectedLink].title,
              shareGroup.links.count > 1 else { return false }
        return true
    }
    
    @ViewBuilder
    var dropdown: some View {
        if let title = shareGroup.links[selectedLink].title, showDropdown {
            Menu {
                ForEach(Array(shareGroup.links.enumerated()), id: \.offset) { index, link in
                    Button(action: {
                        selectedLink = index
                    }) {
                        HStack {
                            Text(link.title ?? "")
                            
                            Spacer()
                            
                            if index == selectedLink {
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
            HStack {
                Text(shareGroup.links[selectedLink].src.absoluteString)
                    .lineLimit(1)
                    .font(.custom("Lato-Medium", size: 18))
                Spacer()
                
                if showDropdown {
                    dropdown
                }
                
                Button {
                    showQRCode = true
                } label: {
                    Image(systemName: "qrcode")
                        .foregroundColor(featuredColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.secondary.opacity(0.4), lineWidth: 1)
            )
            .background(.secondary.opacity(0.1))
            .cornerRadius(6)
            
            ShareLink(
                item: shareGroup.links[selectedLink].src
            ) {
                ShareLabel(shareText: shareText, featuredColor: featuredColor)
            }
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showQRCode) {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showQRCode = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
                
                ShareLink(
                    item: Image(uiImage: qrCodeImage),
                    preview: SharePreview("Image" , image: Image(uiImage: qrCodeImage))
                ) {
                    ShareLabel(shareText: shareText, featuredColor: featuredColor)
                }
                
                Spacer()
            }
            .padding(20)
            .presentationDetents([.medium])
        }
    }
    
    func generateQRCode(from string: String, size: CGFloat = 1024) -> UIImage? {
        let data = string.data(using: .utf8)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else { return nil }

        let scale = size / ciImage.extent.size.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = ciImage.transformed(by: transform)

        let context = CIContext()
        
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }

        return nil
    }
}
