/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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

struct PlayerView: View {
    
    let url: URL?
    
    @State private var player: AVQueuePlayer?
    @State private var videoLooper: AVPlayerLooper?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if let url, player == nil {
                    
                    let templateItem = AVPlayerItem(url: url)
                    
                    player = AVQueuePlayer(playerItem: templateItem)
                    
                    if let player {
                        videoLooper = AVPlayerLooper(player: player, templateItem: templateItem)
                    }
                }
                player?.play()
            }
            .edgesIgnoringSafeArea(.all)
    }
}
