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
import AVKit
import NukeUI
import MediaPlayer

struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.beginAppearanceTransition(true, animated: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player != player {
            uiViewController.player = player
        }
    }
}

class VideoPlayerSegmentViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var played: Bool = false
    @Published var artwork: UIImage? = nil
    
    func setupVideoPlayer(_ url: URL, _ title: String? = nil) {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        
        let playerItem = AVPlayerItem(url: url)
        
        if let title = title {
            let titleMetadata = AVMutableMetadataItem()
            titleMetadata.identifier = AVMetadataIdentifier.commonIdentifierTitle
            titleMetadata.value = title as NSString
            
            playerItem.externalMetadata = [titleMetadata]
        }
        
        player = AVPlayer(playerItem: playerItem)
    }
        
    func setupVideoPlayer(_ video: VideoClipSegment) {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        
        let playerItem = AVPlayerItem(url: video.hls ?? video.src)
        
        var items: [AVMutableMetadataItem] = []
        
        if let title = video.title {
            let titleMetadata = AVMutableMetadataItem()
            titleMetadata.identifier = AVMetadataIdentifier.commonIdentifierTitle
            titleMetadata.value = title as NSString
            items.append(titleMetadata)
        }
        
        if let artist = video.artist {
            let artistMetadata = AVMutableMetadataItem()
            artistMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtist
            artistMetadata.value = artist as NSString
            items.append(artistMetadata)
        }
        
        if !items.isEmpty {
            playerItem.externalMetadata = items
        }
        
        player = AVPlayer(playerItem: playerItem)
        played = false
    }
    
    func play() {
        played = true
        player?.play()
        
        if artwork != nil {
            setThumbnail()
        }
    }
    
    func setThumbnail () {
        if let artwork = artwork {
            let artworkMetadata = AVMutableMetadataItem()
            artworkMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtwork
            artworkMetadata.value = artwork.pngData() as (NSCopying & NSObjectProtocol)?
            
            player?.currentItem?.externalMetadata.append(artworkMetadata)
        }
    }
    
    func getPlayer() -> AVPlayer? {
        return player
    }
}

struct SegmentViewVideo<Content: View>: View {
    var video: [VideoClipSegment]?
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var viewModel = VideoPlayerSegmentViewModel()
    
    @State private var selectedVideo: VideoClipSegment
    @State private var isFullscreen = false
    
    let content: () -> Content
    
    init(video: [VideoClipSegment]?, @ViewBuilder content: @escaping () -> Content) {
        self.video = video
        
        // TODO: avoid ugly code
        self._selectedVideo = State(initialValue: self.video?[safe: 0] ?? VideoClipSegment(
            src: URL(string: "https://this-should-not-happen.com")!,
            artist: nil,
            title: nil,
            thumbnail: nil,
            hls: nil
        ))
        
        self.content = content
    }
    
    var body: some View {
        if let _ = video {
            VStack {
                VStack {
                    if let _ = viewModel.player {
                        FullscreenVideoPlayer(player: viewModel.player!)
                            .background(Color.black)
                            .cornerRadius(6)
                            .overlay {
                                if !viewModel.played {
                                    ZStack(alignment: .center) {
                                        if let thumbnail = selectedVideo.thumbnail {
                                            LazyImage(url: thumbnail) { image in
                                                image.image?.resizable()
                                                    .scaledToFit()
                                                    .onAppear {
                                                        if let thumbnail = image.imageContainer?.image {
                                                            viewModel.artwork = thumbnail
                                                        }
                                                    }
                                            }
                                        }
                                        
                                        Color.black.opacity(0.5)
                                        
                                        Button {
                                            viewModel.play()
                                        } label: {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 53))
                                                .foregroundColor(.white)
                                        }.buttonStyle(.plain)
                                    }.cornerRadius(6)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16/9, contentMode: .fill)
                    }
                }
                .padding()
                .task {
                    if viewModel.player == nil {
                        viewModel.setupVideoPlayer(selectedVideo)
                    }
                }
                
                content()
                
                if let video = self.video, video.count > 1 {
                    VStack {
                        ForEach(Array(video.enumerated()), id: \.offset) { index, clip in
                            if let thumbnail = clip.thumbnail {
                                Button(action: {
                                    if let selectedVideo = self.video?[safe: index] {
                                        self.selectedVideo = selectedVideo
                                        viewModel.setupVideoPlayer(self.selectedVideo)
                                        viewModel.played = true
                                        viewModel.player?.play()
                                    }
                                }) {
                                    HStack (spacing: 10) {
                                        thumbnailView(thumbnail, AppStyle.VideoAux.Size.thumbnail(viewMode: .vertical))
                                        
                                        VStack (spacing: 5) {
                                            if let title = clip.title {
                                                titleView(title)
                                            }
                                            
                                            if let subtitle = clip.artist {
                                                subtitleView(subtitle)
                                            }
                                        }.frame(maxWidth: .infinity)
                                        
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                }.background(selectedVideo == clip ? Color.secondary.opacity(0.2) : .clear)
                            }
                        }
                    }
                }
            }
        }
    }
                                
    @MainActor
    func thumbnailView (_ url: URL, _ size: CGSize? = nil) -> some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image.resizable().aspectRatio(contentMode: .fill)
            } else if state.error != nil {
                
            } else {
                Color(hex: "#cccccc")
            }
        }
        .if(size != nil) { view in
            view.frame(width: size?.width ?? 0, height: size?.height ?? 0)
        }
        .if(size == nil) { view in
            view
                .frame(maxWidth: .infinity)
                .aspectRatio(16 / 9, contentMode: .fill)
        }
        
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
    }
    
    func titleView (_ title: String) -> some View {
        Text(AppStyle.VideoSegment.Text.title(title))
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            
    }
    
    func subtitleView (_ subtitle: String) -> some View {
        Text(AppStyle.VideoSegment.Text.subtitle(subtitle))
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
