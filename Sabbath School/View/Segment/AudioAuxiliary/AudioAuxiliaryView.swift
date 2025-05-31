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
import SwiftAudioEx
import MediaPlayer
import AVKit
import NukeUI

struct AirPlayView: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let routePickerView = AVRoutePickerView()
        routePickerView.activeTintColor = .systemBlue
        routePickerView.tintColor = .black | .white
        routePickerView.prioritizesVideoDevices = true
        return routePickerView
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) { }
}

struct PlayingIndicatorView: UIViewRepresentable {
    func makeUIView(context: Context) -> ESTMusicIndicatorView {
        return ESTMusicIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    }

    func updateUIView(_ uiView: ESTMusicIndicatorView, context: Context) {
        uiView.state = .playing
    }
}

struct AudioAuxiliaryView: View {
    var audio: [Audio]
    var documentIndex: String
    var segmentIndex: String
    
    @EnvironmentObject var audioPlayback: AudioPlayback
    
    @State private var currentIndex: Int = 0
    @State private var showPlaylist: Bool = false

    init(audio: [Audio], documentIndex: String, segmentIndex: String) {
        self.audio = audio
        self.documentIndex = documentIndex
        self.segmentIndex = segmentIndex
    }
    
    @ViewBuilder
    var thumbnail: some View {
        if let audio = audio[safe: currentIndex] {
            LazyImage(url: audio.image.absoluteString.starts(with: "https") ? audio.image : URL(string: "https://sabbath-school.adventech.io/api/v3/images/\(audio.image)")!) { state in
                if let image = state.image {
                    image.resizable()
                        .onAppear {
                            if let uiImage = state.imageContainer?.image {
                                audioPlayback.updateArtwork(uiImage)
                            }
                        }
                }
            }
            .frame(width: audio.imageRatio == "square" ? (showPlaylist ? 110 : 220) : showPlaylist ? 75 : 150, height: showPlaylist ? 110 : 220)
            .cornerRadius(5)
        }
    }
    
    var title: some View {
        VStack (spacing: 10) {
            Text(AppStyle.Audio.title(audioPlayback.player.currentItem?.getTitle() ?? "", small: showPlaylist))
                .multilineTextAlignment(showPlaylist ? .leading : .center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: showPlaylist ? .leading : .center)
            
            Text(AppStyle.Audio.artist(audioPlayback.player.currentItem?.getArtist() ?? "", small: showPlaylist))
                .multilineTextAlignment(showPlaylist ? .leading : .center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: showPlaylist ? .leading : .center)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        let layout = showPlaylist ? AnyLayout(HStackLayout(spacing: 20)) : AnyLayout(VStackLayout(spacing: 20))
        
        VStack(spacing: 20) {
            layout {
                thumbnail
                title
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
            
            VStack (spacing: 0) {
                if showPlaylist {
                    ScrollView(.vertical) {
                        ForEach(Array(audio.enumerated()), id: \.offset) { index, audioItem in
                            Button(action: {
                                currentIndex = index
                                try? audioPlayback.player.jumpToItem(atIndex: index, playWhenReady: true)
                            }) {
                                VStack {
                                    HStack {
                                        VStack(spacing: 10) {
                                            Text(AppStyle.Audio.playlistTitle(audioItem.title, isCurrent: currentIndex == index))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineLimit(1)
                                            
                                            Text(AppStyle.Audio.playlistArtist(audioItem.artist))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineLimit(1)
                                        }
                                        
                                        if audioPlayback.state == .playing && currentIndex == index {
                                            PlayingIndicatorView()
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    
                                    Divider()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        
                    }
                    .layoutPriority(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Spacer()
                }
                
                VStack (spacing: showPlaylist ? 10 : 60) {
                    HStack (spacing: 40) {
                        Button (action: {
                            audioPlayback.player.seek(to: audioPlayback.player.currentTime - 15)
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 25))
                        }

                        Button (action: {
                            audioPlayback.togglePlay()
                        }) {
                            Image(systemName: audioPlayback.state == .playing ? "pause.fill" : "play.fill")
                                .font(.system(size: 50))
                                .fontWeight(.bold)
                                .frame(maxWidth: 50, maxHeight: 50)
                        }
                        
                        Button (action: {
                            audioPlayback.player.seek(to: audioPlayback.player.currentTime + 30)
                        }) {
                            Image(systemName: "goforward.30")
                                .font(.system(size: 25))
                        }
                    }
                    
                    VStack {
                        
                        Slider(value: audioPlayback.duration > audioPlayback.currentTime ? $audioPlayback.currentTime : .constant(0), in: 0...(audioPlayback.duration > audioPlayback.currentTime ? audioPlayback.duration : 1), onEditingChanged: { editing in
                            if editing {
                                audioPlayback.isScrubbing = true
                            } else {
                                audioPlayback.isScrubbing = false
                                audioPlayback.player.seek(to: audioPlayback.currentTime)
                            }
                        })
                        
                        HStack {
                            Text(AppStyle.Audio.time(audioPlayback.currentTime.secondsToString().formatTimeDroppingLeadingZeros()))
                                .lineLimit(1)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            Text(AppStyle.Audio.time("-\((audioPlayback.duration - audioPlayback.currentTime).secondsToString().formatTimeDroppingLeadingZeros())"))
                                .lineLimit(1)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    HStack(spacing: 0) {
                        Menu {
                            Button (action: {
                                audioPlayback.updateRate(.slow)
                            }) {
                                Text(PlaybackRate.slow.label)
                            }
                            
                            Button (action: {
                                audioPlayback.updateRate(.normal)
                            }) {
                                Text(PlaybackRate.normal.label)
                            }
                            
                            Button (action: {
                                audioPlayback.updateRate(.fast)
                            }) {
                                Text(PlaybackRate.fast.label)
                            }
                            
                            Button (action: {
                                audioPlayback.updateRate(.fastest)
                            }) {
                                Text(PlaybackRate.fastest.label)
                            }                            
                        }
                        label : {
                            Text(AppStyle.Audio.rate(audioPlayback.rate.label))
                                .lineLimit(1)
                                .frame(alignment: .leading)
                        }
                        
                        
                        Spacer()
                        
                        AirPlayView().frame(width: 20, height: 20)
                    
                        Spacer()
                        
                        
                        Button(action: {
                            showPlaylist.toggle()
                        }) {
                            Image(systemName: "list.bullet")
                                .imageScale(.large).frame(maxWidth: 20)
                        }
                    }
                    .layoutPriority(1)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity)
                    
                }.padding(.top, showPlaylist ? 60 : 0)
            }
        }
        .accentColor(.black | .white)
        .padding(.horizontal, 20)
        .animation(.spring(duration: 0.3), value: showPlaylist)
        .task {
            let audioItems: [AudioItem] = self.audio.map { $0.audioItem() }
            let defaultIndex: Int = self.audio.firstIndex(where: { $0.targetIndex == self.segmentIndex }) ?? 0
            
            if audioPlayback.state == .playing && audioPlayback.documentIndex == self.documentIndex {
                self.currentIndex = audioPlayback.player.currentIndex
            } else {
                audioPlayback.player.stop()
                audioPlayback.player.clear()
                audioPlayback.stop()
                audioPlayback.player.add(items: audioItems, playWhenReady: false)
                try? audioPlayback.player.jumpToItem(atIndex: defaultIndex, playWhenReady: audioPlayback.state == .playing)
                self.currentIndex = defaultIndex
                audioPlayback.documentIndex = self.documentIndex
            }
        }
    }
}
