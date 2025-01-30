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
import Photos

public struct FullScreenImageViewer: View {
    @Binding var viewerShown: Bool
    @Binding var image: Image?
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGPoint = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastTranslation: CGSize = .zero
    
    @State var caption: String?
    @State private var imageUrl: URL?
    @State private var showingAlert = false

    public init(image: Binding<Image?>, viewerShown: Binding<Bool>, url: URL?, caption: String? = nil) {
        _image = image
        _viewerShown = viewerShown
        _caption = State(initialValue: caption)
        _imageUrl = State(initialValue: url)
    }

    private var displayedImage: Image {
        image ?? Image(systemName: "questionmark.diamond")
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                displayedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(x: offset.x, y: offset.y)
                    .gesture(dragGesture(size: proxy.size))
                    .gesture(magnificationGesture(size: proxy.size))
                    .gesture(dismissGesture())
                
                if let caption, !caption.isEmpty {
                    captionView
                }
                
                topControls
            }
            .alert("Image saved successfully!".localized(), isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private var captionView: some View {
        VStack {
            Spacer()
            Text(caption!)
                .font(.custom("Lato-Italic", size: 17))
                .foregroundColor(.white.opacity(0.7))
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var topControls: some View {
        VStack {
            HStack {
                closeButton
                Spacer()
                downloadButton
            }
            Spacer()
        }
    }
    
    private var closeButton: some View {
        Button(action: { viewerShown = false }) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .font(.system(size: 24))
                .padding()
        }
    }
    
    private var downloadButton: some View {
        Button(action: downloadImage) {
            Image(systemName: "arrow.down.circle")
                .foregroundColor(.white)
                .font(.system(size: 24))
                .padding()
        }
    }
    
    private func magnificationGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale *= delta
            }
            .onEnded { _ in
                lastScale = 1
                withAnimation { scale = max(scale, 1) }
                adjustMaxOffset(size: size)
            }
    }
    
    private func dragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let diff = CGPoint(
                    x: value.translation.width - lastTranslation.width,
                    y: value.translation.height - lastTranslation.height
                )
                offset.x += diff.x
                offset.y += diff.y
                lastTranslation = value.translation
            }
            .onEnded { _ in adjustMaxOffset(size: size) }
    }
    
    private func dismissGesture() -> some Gesture {
        DragGesture()
            .onEnded { value in
                if abs(value.translation.height) > 200 {
                    withAnimation(.spring()) { viewerShown = false }
                }
            }
    }
    
    private func adjustMaxOffset(size: CGSize) {
        let maxOffsetX = (size.width * (scale - 1)) / 2
        let maxOffsetY = (size.height * (scale - 1)) / 2
        
        offset.x = max(-maxOffsetX, min(maxOffsetX, offset.x))
        offset.y = max(-maxOffsetY, min(maxOffsetY, offset.y))
        
        lastTranslation = .zero
    }
    
    private func downloadImage() {
        guard let url = imageUrl else {
            print("No URL available for downloading.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("Permission denied")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            showingAlert = true
                        } else {
                            print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }.resume()
    }
}
