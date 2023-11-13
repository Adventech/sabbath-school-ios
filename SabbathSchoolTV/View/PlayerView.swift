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
    
    let clip: Clip
    
    @State private var player: AVQueuePlayer?
    @State private var videoLooper: AVPlayerLooper?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if let url = clip.url, player == nil {
                    
                    let templateItem = AVPlayerItem(url: url)
                    templateItem.externalMetadata = createMetadataItems(for: clip)
                    player = AVQueuePlayer(playerItem: templateItem)
                    
                    if let player {
                        videoLooper = AVPlayerLooper(player: player, templateItem: templateItem)
                    }
                }
                player?.play()
            }
            .edgesIgnoringSafeArea(.all)
    }
    
    private func createMetadataItems(for metadata: Clip) -> [AVMetadataItem] {
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: metadata.title,
            .iTunesMetadataReleaseDate: metadata.artist
        ]
        return mapping.compactMap { createMetadataItem(for:$0, value:$1) }
    }
    
    
    private func createMetadataItem(for identifier: AVMetadataIdentifier,
                                    value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
}
