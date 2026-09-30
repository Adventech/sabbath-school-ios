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

extension DocumentView {
    @ViewBuilder
    func miniPlayerView () -> some View {
        if let segment = viewModel.document?.segments?[documentViewOperator.activeTab] {
            if audioPlayback.shouldShowMiniPlayer() && (
                segment.type != .story || (segment.type == .story && documentViewOperator.shouldShowNavigationBar)
            ) {
                Button(action: {
                    showAudioAux = true
                }) {
                    HStack {
                        Button (action: {
                            miniPlayerStop()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                        
                        VStack(alignment: .leading) {
                            Text(AppStyle.Audio.miniPlayerTitle(audioPlayback.player.currentItem?.getTitle() ?? ""))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                                .frame(alignment: .leading)
                            
                            Text(AppStyle.Audio.miniPlayerArtist(audioPlayback.player.currentItem?.getArtist() ?? ""))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                                .frame(alignment: .leading)
                        }.frame(alignment: .leading)
                        
                        Spacer()
                        
                        Button (action: {
                            miniPlayerRewind()
                        }) {
                            Image(systemName: "gobackward.15")
                                .imageScale(.medium)
                        }
                        
                        Button (action: {
                            miniPlayerPausePlay()
                        }) {
                            Image(systemName: audioPlayback.state == .playing ? "pause.fill" : "play.fill")
                                .imageScale(.large)
                        }
                    }
                    .frame(height: AppStyle.Audio.miniPlayerHeight)
                    .padding(.horizontal, AppStyle.Audio.miniPlayerContentPadding)
                    .frame(width: screenSizeMonitor.screenSize.width - AppStyle.Segment.Spacing.horizontalPaddingHeader(screenSizeMonitor.screenSize.width) * 2)
                    .modifier(FloatingControlSurface(cornerRadius: AppStyle.Audio.miniPlayerCornerRadius))
                }.buttonStyle(.plain)
            }
        }
    }
    
    func miniPlayerPausePlay () {
        audioPlayback.togglePlay()
    }
    
    func miniPlayerRewind () {
        audioPlayback.player.seek(to: audioPlayback.player.currentTime - 15)
    }
    
    func miniPlayerStop () {
        audioPlayback.stop()
    }
}
