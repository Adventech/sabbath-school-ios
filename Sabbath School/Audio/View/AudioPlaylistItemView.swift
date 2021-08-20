/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

import AsyncDisplayKit

final class AudioPlaylistItemView: ASCellNode {
    let audio: Audio!
    let title = ASTextNode()
    let artist = ASTextNode()
    let playingIndicator = ASDisplayNode { ESTMusicIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20)) }
    var playingIndicatorView: ESTMusicIndicatorView { return playingIndicator.view as! ESTMusicIndicatorView }
    var isPlaying: Bool = false
    
    init(audio: Audio) {
        self.audio = audio
        super.init()
        
        self.backgroundColor = AppStyle.Base.Color.background
        title.attributedText = AppStyle.Audio.Text.playlistTitle(string: audio.title)
        title.maximumNumberOfLines = 2
        artist.attributedText = AppStyle.Audio.Text.playlistArtist(string: audio.artist)
        artist.maximumNumberOfLines = 1
        automaticallyManagesSubnodes = true
        selectionStyle = .none
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        title.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        playingIndicator.style.preferredSize = CGSize(width: 20, height: 30)
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [title, artist]
        )
        
        
        vSpec.style.flexShrink = 1.0
        vSpec.style.flexGrow = 1.0
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: .center,
            children: [vSpec, playingIndicator]
        )

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0), child: hSpec)
    }
    
    func setCurrent() {
        title.attributedText = AppStyle.Audio.Text.playlistTitle(string: audio.title, isCurrent: true)
    }
    
    func setPlayingIndicator(isPlaying: Bool) {
        self.isPlaying = isPlaying
        playingIndicatorView.state = isPlaying ? .playing : .stopped
    }
    
    func reset() {
        title.attributedText = AppStyle.Audio.Text.playlistTitle(string: audio.title)
        playingIndicatorView.state = .stopped
    }
    
    override func didLoad() {
        super.didLoad()
        playingIndicatorView.tintColor = .baseBlue
        playingIndicatorView.backgroundColor = .clear
        playingIndicatorView.state = .stopped
    }
    
    override func layout() {
        super.layout()
        setPlayingIndicator(isPlaying: self.isPlaying)
    }
}
