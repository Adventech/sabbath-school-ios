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

class AudioMiniPlayerView: ASDisplayNode {
    let artist = ASTextNode()
    let title = ASTextNode()
    let play = ReadButtonNode()
    let backward = ReadButtonNode()
    let close = ASImageNode()
    
    override init() {
        super.init()
        backgroundColor = AppStyle.Audio.Color.miniPlayerBackground
        cornerRadius = 10
        title.attributedText = AppStyle.Audio.Text.miniPlayerTitle(string: "")
        title.maximumNumberOfLines = 1
        title.truncationMode = .byTruncatingTail
        artist.attributedText = AppStyle.Audio.Text.miniPlayerArtist(string: "")
        artist.maximumNumberOfLines = 1
        artist.truncationMode = .byTruncatingTail
        play.setImage(R.image.iconAudioPlay(), for: .normal)
        play.setImage(R.image.iconAudioPause(), for: .selected)
        backward.setImage(R.image.iconAudioBackward(), for: .normal)
        close.image = R.image.iconClose()?.fillAlpha(fillColor: .baseGray2)
        
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        close.style.preferredSize = CGSize(width: 15, height: 15)
        close.style.spacingAfter = 5
        close.hitTestSlop = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        play.style.preferredSize = CGSize(width: 20.54, height: 23)
        play.imageNode.style.preferredSize = CGSize(width: 20.54, height: 23)
        backward.style.preferredSize = CGSize(width: 20.44, height: 23)
        backward.imageNode.style.preferredSize = CGSize(width: 20.44, height: 23)
        
        let playControls = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [backward, play]
        )
        
        let width: CGFloat = AppStyle.Audio.Size.miniPlayerWidth(constrainedWidth: constrainedSize.max.width-80)
        let info = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [title, artist]
        )
        
        info.style.flexShrink = 1.0
        info.style.flexGrow = 1.0
        info.style.minWidth = ASDimensionMakeWithPoints(width)
        info.style.maxWidth = ASDimensionMakeWithPoints(width)
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [close, info, playControls]
        )
        
        hSpec.style.minWidth = ASDimensionMakeWithPoints(width)
        hSpec.style.maxWidth = ASDimensionMakeWithPoints(width)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20), child: hSpec)
    }
}
