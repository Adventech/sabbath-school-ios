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
import UIKit
import SwiftAudio
import MediaPlayer

extension Audio {
    func audioItem() -> AudioItem {
        return DefaultAudioItem(
            audioUrl: self.src.absoluteString,
            artist: self.artist,
            title: self.title,
            sourceType: .stream
        )
    }
}

class AudioController: ASDKViewController<ASDisplayNode> {
    let audioView = AudioView()
    var isScrubbing = false
    var dataSource: [Audio] = []
    var lessonIndex: String?
    var dayIndex: String?
    
    init(audio: [Audio], lessonIndex: String? = nil, dayIndex: String? = nil) {
        self.dayIndex = dayIndex
        self.lessonIndex = lessonIndex
        self.dataSource = audio
        
        super.init(node: audioView)
        audioView.playlist.dataSource = self
        audioView.playlist.delegate = self
        audioView.cover.imageNode.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCloseButton()
        self.navigationController?.navigationBar.isTranslucent = false
        
        audioView.play.addTarget(self, action: #selector(didPressPlay(_:)), forControlEvents: .touchUpInside)
        audioView.progressView.addTarget(self, action: #selector(didSeek(_:)), for: .valueChanged)
        audioView.progressView.addTarget(self, action: #selector(didStartSeek(_:)), for: .touchDown)
        audioView.progressView.addTarget(self, action: #selector(didEndSeek(_:)), for: [.touchUpInside, .touchUpOutside])
        audioView.forward.addTarget(self, action: #selector(didPressForward(_:)), forControlEvents: .touchUpInside)
        audioView.backward.addTarget(self, action: #selector(didPressBackward(_:)), forControlEvents: .touchUpInside)
        audioView.rate.addTarget(self, action: #selector(didPressRate(_:)), forControlEvents: .touchUpInside)
        audioView.airplay.addTarget(self, action: #selector(showAirPlayMenu(_:)), forControlEvents: .touchUpInside)
        
        AudioPlayback.shared.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        AudioPlayback.shared.event.secondElapse.addListener(self, handleAudioPlayerSecondElapsed)
        AudioPlayback.shared.event.updateDuration.addListener(self, handleAudioPlayerUpdateDuration)
        AudioPlayback.shared.event.seek.addListener(self, handleAudioPlayerDidSeek)

        updateAudio()
        handleAudioPlayerStateChange(state: AudioPlayback.shared.playerState)
        

        if AudioPlayback.shared.currentItem != nil {
            if let lessonIndex = lessonIndex, lessonIndex == AudioPlayback.lessonIndex {
                if AudioPlayback.shared.playerState == .playing && AudioPlayback.shared.items.map({ $0.getSourceUrl() }) == self.dataSource.map({ $0.src.absoluteString }) {
                    return
                }
            }
            AudioPlayback.shared.stop()
        }
        
        AudioPlayback.lessonIndex = lessonIndex
        let audioItems: [AudioItem] = self.dataSource.map { $0.audioItem() }
        let defaultIndex: Int = dayIndex != nil ? self.dataSource.firstIndex(where: { $0.targetIndex == self.dayIndex! }) ?? 0 : 0
        try? AudioPlayback.shared.add(items: audioItems, playWhenReady: false)        
        try? AudioPlayback.shared.jumpToItem(atIndex: defaultIndex, playWhenReady: AudioPlayback.shared.playerState == .playing)
    }
    
    @objc func showAirPlayMenu(_ sender: ASImageNode) {
        let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let airplayVolume = MPVolumeView(frame: rect)
        airplayVolume.showsVolumeSlider = false
        self.view.addSubview(airplayVolume)
        for view: UIView in airplayVolume.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
        airplayVolume.removeFromSuperview()
    }
    
    @objc func didPressPlay(_ sender: ASButtonNode) {
        if sender.isSelected {
            AudioPlayback.pause()
        } else {
            AudioPlayback.play()
        }
    }
    
    @objc func didPressForward(_ sender: ASButtonNode) {
        AudioPlayback.shared.seek(to: AudioPlayback.shared.currentTime + 30)
    }
    
    @objc func didPressBackward(_ sender: ASButtonNode) {
        AudioPlayback.shared.seek(to: AudioPlayback.shared.currentTime - 15)
    }
    
    @objc func didPressRate(_ sender: ASTextNode) {
        let currentRate = AudioPlayback.rate
        var newRate: AudioRate

        switch currentRate {
        case .slow:
            newRate = AudioRate.normal
            break
        case .normal:
            newRate = AudioRate.fast
            break
        case .fast:
            newRate = AudioRate.fastest
            break
        case .fastest:
            newRate = AudioRate.slow
            break
        }
        
        AudioPlayback.rate = newRate
        
        if AudioPlayback.shared.rate > 0 {
            AudioPlayback.shared.rate = AudioPlayback.rate.val
        }
        
        updateRate(rate: newRate)
    }
    
    @objc func didStartSeek(_ sender: ProgressSlider) {
        isScrubbing = true
    }
    
    @objc func didEndSeek(_ sender: ProgressSlider) {
        isScrubbing = false
    }
    
    @objc func didSeek(_ sender: ProgressSlider) {
        AudioPlayback.shared.seek(to: Double(sender.value))
    }
    
    func updateAudio() {
        if let item = AudioPlayback.shared.currentItem {
            self.audioView.setTitle(string: item.getTitle() ?? "")
            self.audioView.setArtist(string: item.getArtist() ?? "")
            
            if let audio = self.dataSource.first(where: { $0.src.absoluteString == item.getSourceUrl() }) {
                self.audioView.coverRatio = audio.imageRatio
                self.audioView.cover.imageNode.url = audio.image
            }
        }
    }
    
    func updateRate(rate: AudioRate) {
        self.audioView.rate.attributedText = AppStyle.Audio.Text.rate(string: rate.label)
    }
    
    func updateTimeValues() {
        self.audioView.progressView.maximumValue = Float(AudioPlayback.shared.duration)
        self.audioView.progressView.setValue(Float(AudioPlayback.shared.currentTime), animated: true)
        
        self.audioView.remaining.attributedText = AppStyle.Audio.Text.time(string: "-" + (AudioPlayback.shared.duration - AudioPlayback.shared.currentTime).secondsToString().formatTimeDroppingLeadingZeros())
        
        self.audioView.elapsed.attributedText = AppStyle.Audio.Text.time(string: AudioPlayback.shared.currentTime.secondsToString().formatTimeDroppingLeadingZeros())
    }
    
    func updatePlayPauseState(state: AudioPlayerState) {
        self.audioView.play.isSelected = state == .playing
    }
    
    func updatePlaylist() {
        if AudioPlayback.shared.currentItem != nil {
            for index in 0...dataSource.count-1 {
                let audioPlaylistItemView: AudioPlaylistItemView = self.audioView.playlist.nodeForRow(at: IndexPath(row: index, section: 0)) as! AudioPlaylistItemView
                if index == AudioPlayback.shared.currentIndex {
                    audioPlaylistItemView.setCurrent()
                    audioPlaylistItemView.setPlayingIndicator(isPlaying: AudioPlayback.shared.playerState == .playing)
                    
                    if !self.audioView.playlistExpanded {
                        self.audioView.playlist.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
                    }
                } else {
                    audioPlaylistItemView.reset()
                }
            }
        }
    }
    
    func handleAudioPlayerSecondElapsed(data: AudioPlayer.SecondElapseEventData) {
        if !isScrubbing {
            DispatchQueue.main.async {
                self.updateTimeValues()
            }
        }
    }
    
    func handleAudioPlayerUpdateDuration(data: AudioPlayer.UpdateDurationEventData) {
        DispatchQueue.main.async {
            self.updateTimeValues()
        }
    }
    
    func handleAudioPlayerDidSeek(data: AudioPlayer.SeekEventData) {
        isScrubbing = false
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayer.StateChangeEventData) {
        DispatchQueue.main.async {
            self.updatePlayPauseState(state: state)
            switch state {
            case .loading, .ready:
                self.updateAudio()
                self.updateTimeValues()
            case .playing:
                self.updateAudio()
                AudioPlayback.shared.rate = AudioPlayback.rate.val
                self.updateRate(rate: AudioPlayback.rate)
                self.updateTimeValues()
                self.updatePlaylist()
            case .paused, .idle:
                self.updatePlaylist()
                self.updateTimeValues()
            default:
                break
            }
        }
    }
}

extension AudioController: ASTableDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        try? AudioPlayback.shared.jumpToItem(atIndex: indexPath.row, playWhenReady: true)
    }
}

extension AudioController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            if self.dataSource.count > 0 {
                return AudioPlaylistItemView(audio: self.dataSource[indexPath.row])
            }
            return AudioPlaylistItemEmptyView()
        }
        return cellNodeBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension AudioController: ASNetworkImageNodeDelegate {
    func imageNodeDidFinishDecoding(_ imageNode: ASNetworkImageNode) {
        guard let cover = imageNode.image else { return }
        let artwork = MPMediaItemArtwork(boundsSize: cover.size, requestHandler: { (size) -> UIImage in
            return cover
        })
        AudioPlayback.shared.nowPlayingInfoController.set(keyValue: MediaItemProperty.artwork(artwork))
    }
}
