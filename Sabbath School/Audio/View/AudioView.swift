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
import AVFoundation
import UIKit
import MediaPlayer

class AudioView: ASDisplayNode {
    let coverCornerRadius = CGFloat(6)
    let topIndicator = ASDisplayNode()
    
    let play = ASButtonNode()
    let backward = ASButtonNode()
    let forward = ASButtonNode()
    
    let rate = ASTextNode()
    let airplay = ASImageNode()
    let playlistToggle = ASImageNode()
    
    let title = ASTextNode()
    let artist = ASTextNode()
    
    let elapsed = ASTextNode()
    let remaining = ASTextNode()
    
    let volume = ASDisplayNode {
        MPVolumeView(frame: CGRect(x: 0, y: 0, width: 100, height: 18))
    }
    
    var volumeView: MPVolumeView { return volume.view as! MPVolumeView }
    
    let progress = ASDisplayNode {
        ProgressSlider(frame: CGRect(x: 0, y: 0, width: 100, height: 18))
    }
    
    var progressView: ProgressSlider { return progress.view as! ProgressSlider }
    
    let volumeMin = ASImageNode()
    let volumeMax = ASImageNode()
    
    var cover: RoundedCornersImage!
    let coverBackground = ASDisplayNode()
    
    let playlist = ASTableNode()
    
    var coverRatio: String = "square"
    var playlistExpanded = false
    
    var coverSize: CGSize {
        return AppStyle.Audio.Size.coverImage(coverRatio: coverRatio, isMini: playlistExpanded)
    }
    
    var bottomArea: CGFloat = 0

    override init() {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        
        topIndicator.cornerRadius = 3
        topIndicator.backgroundColor = AppStyle.Audio.Color.topIndicator
        
        play.setImage(R.image.iconAudioPlay(), for: .normal)
        play.setImage(R.image.iconAudioPause(), for: .selected)
        
        backward.setImage(R.image.iconAudioBackward(), for: .normal)
        forward.setImage(R.image.iconAudioForward(), for: .normal)
        
        airplay.image = R.image.iconAudioAirplay()?.fillAlpha(fillColor: AppStyle.Audio.Color.auxControls)
        playlistToggle.image = R.image.iconAudioPlaylist()?.fillAlpha(fillColor: AppStyle.Audio.Color.auxControls)
        
        volumeMin.image = R.image.iconAudioVolumeMin()?.fillAlpha(fillColor: .baseGray2)
        volumeMax.image = R.image.iconAudioVolumeMax()?.fillAlpha(fillColor: .baseGray2)
        
        title.maximumNumberOfLines = 2
        artist.maximumNumberOfLines = 1
        
        setTitle(string: "")
        setArtist(string: "")
        
        rate.attributedText = AppStyle.Audio.Text.rate(string: "1×")
        elapsed.attributedText = AppStyle.Audio.Text.time(string: "0:00")
        remaining.attributedText = AppStyle.Audio.Text.time(string: "0:00")
        
        volumeView.showsRouteButton = false
        volumeView.tintColor = .baseWhite1.darker()
        volumeView.backgroundColor = .baseGray1.lighter(componentDelta: 0.6)
        
        progressView.setThumbImage(R.image.iconAudioProgressSmall()?.fillAlpha(fillColor: AppStyle.Audio.Color.progressThumb), for: .normal)
        progressView.setThumbImage(R.image.iconAudioProgressLarge()?.fillAlpha(fillColor: AppStyle.Audio.Color.progressThumb), for: .highlighted)
        progressView.tintColor = AppStyle.Audio.Color.progressThumb
        progressView.maximumTrackTintColor = AppStyle.Audio.Color.progressTint
        progressView.minimumValue = 0
        progressView.maximumValue = 1.0
        progressView.isContinuous = false
        
        coverBackground.cornerRadius = coverCornerRadius
        coverBackground.clipsToBounds = false
        
        var coverPlaceholder: URL? = nil
        
        if let resourceUrl = R.image.iconAudioCoverPlaceholder.bundle.resourceURL {
            coverPlaceholder = URL.init(string: resourceUrl.absoluteString + "/icon-audio-cover-placeholder")
        }
        
        cover = RoundedCornersImage(
            imageURL: coverPlaceholder,
            corner: coverCornerRadius,
            size: coverSize,
            backgroundColor: AppStyle.Base.Color.background
        )
        
        cover.shadowColor = UIColor.baseGray3.cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 10
        cover.shadowOpacity = 0.3
        cover.clipsToBounds = false
        
        cover.style.alignSelf = .stretch
        
        DispatchQueue.main.async {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                if let bottomPadding = window?.safeAreaInsets.bottom {
                    self.bottomArea = bottomPadding
                }
            }
        }

        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        playlist.view.separatorColor = AppStyle.Base.Color.tableSeparator
        playlist.view.backgroundColor = AppStyle.Base.Color.background
        playlistToggle.addTarget(self, action: #selector(didPlaylistToggle(_:)), forControlEvents: .touchUpInside)
    }
    
    override func layout() {
        super.layout()
        playlist.view.separatorColor = AppStyle.Base.Color.tableSeparator
    }
    
    func setTitle(string: String?) {
        title.attributedText = AppStyle.Audio.Text.title(
            string: string ?? self.title.attributedText?.string ?? "",
            alignment: playlistExpanded ? .left : .center
        )
    }
    
    func setArtist(string: String?) {
        artist.attributedText = AppStyle.Audio.Text.artist(
            string: string ?? self.title.attributedText?.string ?? "",
            alignment: playlistExpanded ? .left : .center
        )
    }
    
    @objc func didPlaylistToggle(_ sender: ASButtonNode) {
        playlistExpanded = !playlistExpanded
        transitionLayout(withAnimation: true, shouldMeasureAsync: true)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cover.style.preferredSize = coverSize
        coverBackground.style.preferredSize = coverSize
        
        playlist.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(0))
        playlist.style.flexGrow = 1.0
        playlist.style.spacingAfter = 10
        playlist.style.spacingBefore = 20
        
        progress.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width-54), height: ASDimensionMake(10))
        
        topIndicator.style.preferredSize = CGSize(width: 50, height: 5)
        play.style.preferredSize = CGSize(width: 32.15, height: 36)
        play.imageNode.style.preferredSize = CGSize(width: 32.15, height: 36)
        
        backward.style.preferredSize = CGSize(width: 25.57, height: 28)
        backward.imageNode.style.preferredSize = CGSize(width: 25.57, height: 28)
        forward.style.preferredSize = CGSize(width: 25.57, height: 28)
        forward.imageNode.style.preferredSize = CGSize(width: 25.57, height: 28)
        backward.style.spacingAfter = 60
        forward.style.spacingBefore = 60
        
        volume.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width-100), height: ASDimensionMake(18))
        volumeMin.style.preferredSize = CGSize(width: 8.05, height: 12)
        volumeMax.style.preferredSize = CGSize(width: 16.5, height: 12)
        
        rate.hitTestSlop = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        airplay.style.preferredSize = CGSize(width: 18, height: 18)
        airplay.hitTestSlop = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        playlistToggle.style.preferredSize = CGSize(width: 18, height: 13.05)
        playlistToggle.hitTestSlop = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        
        let coverSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [cover])
        
        let infoSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .center,
            alignItems: playlistExpanded ? .start : .center,
            children: [title, artist])
        
        var topSpecChildren: [ASLayoutElement] = []
        
        if #available(iOS 13, *) {
            topSpecChildren.append(topIndicator)
        }
        
        if playlistExpanded {
            let coverHSpec = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 10,
                justifyContent: .start,
                alignItems: .center,
                children: [coverSpec, infoSpec])
            
            coverHSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width-20)
            coverHSpec.style.spacingBefore = 10
            infoSpec.style.flexShrink = 1.0
            
            topSpecChildren.append(coverHSpec)
        }
        
        let topSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: topSpecChildren)
        
        var middleSpecChildren: [ASLayoutElement] = []
        
        if !playlistExpanded {
            middleSpecChildren.append(coverSpec)
        } else {
            middleSpecChildren.append(playlist)
        }
        
        let middleSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: middleSpecChildren)
        
        middleSpec.style.flexGrow = 1.0
        
        let progressTimeSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [elapsed, remaining])
        
        let progressSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [progress, progressTimeSpec])
        
        let playbackControlsSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [backward, play, forward])
        
        progressTimeSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        progressSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        playbackControlsSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)

        let volumeSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: .center,
            children: [volumeMin, volume, volumeMax])
        
        let auxilarySpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [rate, airplay, playlistToggle])
        
        rate.style.flexBasis = ASDimensionMakeWithPoints(40)
        playlistToggle.style.spacingBefore = 20
        auxilarySpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        
        var bottomSpecChildren: [ASLayoutElement] = [progressSpec, playbackControlsSpec, volumeSpec, auxilarySpec]
        
        if !playlistExpanded {
            infoSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
            bottomSpecChildren.insert(infoSpec, at: 0)
        }
        
        let bottomSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: bottomSpecChildren)
        
        bottomSpec.style.maxHeight = ASDimensionMakeWithPoints(playlistExpanded ? constrainedSize.max.height/4 : constrainedSize.max.height/2)
        bottomSpec.style.minHeight = ASDimensionMakeWithPoints(playlistExpanded ? constrainedSize.max.height/4 : constrainedSize.max.height/2)
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [topSpec, middleSpec, bottomSpec])
        
        mainSpec.style.minHeight = ASDimensionMakeWithPoints(constrainedSize.max.height)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 25, bottom: 15 + bottomArea, right: 25), child: mainSpec)
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.cover.frame = context.finalFrame(for: self.cover)
                self.play.frame = context.finalFrame(for: self.play)
                self.backward.frame = context.finalFrame(for: self.backward)
                self.forward.frame = context.finalFrame(for: self.forward)
                self.artist.frame = context.finalFrame(for: self.artist)
                self.title.frame = context.finalFrame(for: self.title)
                self.progress.frame = context.finalFrame(for: self.progress)
                self.volume.frame = context.finalFrame(for: self.volume)
                self.volumeMin.frame = context.finalFrame(for: self.volumeMin)
                self.volumeMax.frame = context.finalFrame(for: self.volumeMax)
                self.elapsed.frame = context.finalFrame(for: self.elapsed)
                self.remaining.frame = context.finalFrame(for: self.remaining)
                
                self.playlist.alpha = self.playlistExpanded ? 1 : 0
                
                if self.playlistExpanded {
                    self.playlist.frame = context.finalFrame(for: self.playlist)
                }
                
                self.layoutIfNeeded()
            },
            completion: { finished in
                context.completeTransition(finished)
            }
        )
    }
}
