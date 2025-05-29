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
    
    @State private var showDownloadSuccess = false
    @State private var baseImageSize: CGSize = .zero
    @State private var maximumScale: CGFloat = 4.0
    
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
        GeometryReader { containerProxy in
            let containerSize = containerProxy.size
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                displayedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    baseImageSize = geo.size
                                }
                                .onChange(of: geo.size) { newSize in
                                    baseImageSize = newSize
                                }
                        }
                    )
                    .scaleEffect(scale)
                    .offset(x: offset.x, y: offset.y)
                    .gesture(dragGesture(for: containerSize))
                    .gesture(magnificationGesture(for: containerSize))
                    .gesture(dismissGesture())
                    .simultaneousGesture(
                        TapGesture(count: 2).onEnded {
                            withAnimation(.spring()) {
                                if scale == 1 {
                                    scale = maximumScale
                                } else {
                                    scale = 1
                                    offset = .zero
                                }
                            }
                        }
                    )
                
                if let caption, !caption.isEmpty {
                    captionView
                }
                topControls
                if showDownloadSuccess {
                    downloadSuccessView
                        .transition(.scale)
                }
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
    
    private var downloadSuccessView: some View {
        CheckmarkAnimationView()
            .frame(width: 80, height: 80)
    }
    
    private func dragGesture(for containerSize: CGSize) -> some Gesture {
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
            .onEnded { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    offset = clampedOffset(for: containerSize)
                    lastTranslation = .zero
                }
            }
    }
    
    private func magnificationGesture(for containerSize: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                let newScale = scale * delta
                scale = min(newScale, maximumScale)
            }
            .onEnded { _ in
                lastScale = 1
                withAnimation(.spring()) {
                    scale = max(1, min(scale, maximumScale))
                    offset = clampedOffset(for: containerSize)
                }
            }
    }
    
    private func dismissGesture() -> some Gesture {
        DragGesture()
            .onEnded { value in
                if abs(value.translation.height) > 200 {
                    withAnimation(.spring()) {
                        viewerShown = false
                    }
                }
            }
    }
    
    private func clampedOffset(for containerSize: CGSize) -> CGPoint {
        let effectiveWidth = baseImageSize.width * scale
        let effectiveHeight = baseImageSize.height * scale
        
        let clampedX: CGFloat
        if effectiveWidth > containerSize.width {
            let maxOffsetX = (effectiveWidth - containerSize.width) / 2
            clampedX = max(-maxOffsetX, min(maxOffsetX, offset.x))
        } else {
            // Center horizontally
            clampedX = 0
        }
        
        let clampedY: CGFloat
        if effectiveHeight > containerSize.height {
            let maxOffsetY = (effectiveHeight - containerSize.height) / 2
            clampedY = max(-maxOffsetY, min(maxOffsetY, offset.y))
        } else {
            // Center vertically
            clampedY = 0
        }
        
        return CGPoint(x: clampedX, y: clampedY)
    }
    
    private func downloadImage() {
        guard let url = imageUrl else {
            print("No URL available for downloading.")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  error == nil,
                  let uiImage = UIImage(data: data) else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("Permission denied")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            withAnimation(.spring()) {
                                showDownloadSuccess = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.spring()) {
                                    showDownloadSuccess = false
                                }
                            }
                        } else {
                            print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }.resume()
    }
}
