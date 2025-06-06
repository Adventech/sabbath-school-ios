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
import AVFoundation

class AudioPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var timeObserverToken: Any?
    @Published var statusObserver: NSKeyValueObservation?
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    
    @Published var finished = false
    
    @Published var onFinished: (() -> Void)?
    
    func setupAudioPlayer(_ url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        setupTimeObserver()
    }
    
    private func setupTimeObserver() {
        guard let player else { return }
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self, let currentItem = player.currentItem else { return }
            self.currentTime = time.seconds
            self.duration = currentItem.duration.seconds
        }
        
        statusObserver = player.currentItem?.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            if item.status == .readyToPlay {
                self?.duration = item.duration.seconds
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func playPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        let time = CMTime(seconds: time, preferredTimescale: 1)
        player?.seek(to: time)
    }
    
    @objc private func audioDidFinishPlaying() {
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
        finished = true
        onFinished?()
    }
    
    deinit {
        guard let timeObserverToken else { return }
        player?.removeTimeObserver(timeObserverToken)

        self.timeObserverToken = nil
        NotificationCenter.default.removeObserver(self)
    }
}

struct BlockAudioViewCredits: View {
    var credits: AudioBlockCredits
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Rectangle()
                    .fill(Color(uiColor: .baseGray1 | .baseGray2))
                    .cornerRadius(3)
                    .frame(width: 50, height: 5)
    
                VStack (spacing: 40) {
                    Text(AppStyle.Base.navigationTitle(credits.title ?? "Credits".localized()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(Array(credits.credits.enumerated()), id: \.offset) { index, credit in
                        VStack {
                            Text(credit.key)
                                .font(.custom("Lato-Bold", size: 18))
                                .lineLimit(1)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                            
                            Text(credit.value)
                                .font(.custom("Lato-Regular", size: 18))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let copyright = credits.copyright {
                        Text(copyright)
                            .font(.custom("Lato-Italic", size: 15))
                            .foregroundColor((.black | .white).opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity)
            }
            .padding(.top, 10)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BlockAudioView: View {
    var block: AudioBlock
    
    @State private var showCredits: Bool = false
    
    @StateObject var viewModel = AudioPlayerViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inlineAudioPlaybackManager: InlineAudioPlaybackManager
    
    var body: some View {
        VStack (spacing: 10){
            if let _ = viewModel.player {
                HStack {
                    Button(action: {
                        viewModel.playPause()
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(AppStyle.Block.genericForegroundColorForInteractiveBlock(theme: themeManager.currentTheme))
                    }
                    
                    Text("\(formatTime(viewModel.currentTime))")
                        .font(.custom("Lato-Regular", size: 14))
                        .foregroundColor(AppStyle.Block.genericForegroundColorForInteractiveBlock(theme: themeManager.currentTheme))
                    
                    Spacer()
                    
                    if viewModel.duration > 0 {
                        Slider(value: $viewModel.currentTime, in: 0...viewModel.duration, onEditingChanged: { editing in
                            if !editing {
                                viewModel.seek(to: viewModel.currentTime)
                            }
                        }).controlSize(.small)
                    }
                }
                .padding(10)
                .background(AppStyle.Block.genericBackgroundColorForInteractiveBlock(theme: themeManager.currentTheme))
                .cornerRadius(6)
                
                if let caption = block.caption {
                    VStack {
                        Text(caption)
                            .font(.custom("Lato-Italic", size: 14))
                            .foregroundColor(
                                AppStyle.Block.genericForegroundColorForInteractiveBlock(theme: themeManager.currentTheme)
                            )
                        
                        if let credits = block.credits {
                            Button (action: {
                                showCredits.toggle()
                            }) {
                                Text(credits.title ?? "Credits".localized())
                                    .font(.custom("Lato-Regular", size: 14))
                                    .underline()
                                    .foregroundColor(
                                        AppStyle.Block.genericForegroundColorForInteractiveBlock(theme: themeManager.currentTheme)
                                    )
                            }
                        }
                    }
                }
            }
        }.task {
            if viewModel.player == nil {
                viewModel.setupAudioPlayer(block.src)
                viewModel.onFinished = {
                    inlineAudioPlaybackManager.finishedPlaying(blockId: self.block.id)
                }
            }
        }.sheet(isPresented: $showCredits) {
            if let credits = block.credits {
                BlockAudioViewCredits(credits: credits)
            }
        }.onChange(of: inlineAudioPlaybackManager.nextUp) { newValue in
            if newValue == block.id {
                viewModel.playPause()
            }
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BlockAudioView(
            block: AudioBlock(
                id: "audio-block",
                type: .audio,
                style: nil,
                data: nil,
                src: URL(string: "https://sabbath-school-media-stage.adventech.io/audio/en/2024-02/00b0f29167d9677ddcf832ddf7f94ec7f50184b45ee7926242cd99d4a53a00c3/00b0f29167d9677ddcf832ddf7f94ec7f50184b45ee7926242cd99d4a53a00c3.mp3")!,
                caption: "Caption",
                nested: false,
                credits: nil
            )
        )
    }
}
