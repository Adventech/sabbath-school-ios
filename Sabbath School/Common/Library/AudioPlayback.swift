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

import AVFoundation
import MediaPlayer

extension Notification.Name {
    static let didReceiveAudioEvent = Notification.Name("didReceiveAudioEvent")
}

enum AudioEvent: String {
    case play
    case pause
    case timestamp
    case duration
}

class AudioPlayback: NSObject {
    // Singleton to keep audio playing anywhere
    static let shared = AudioPlayback()
    private static var context = 0
    var player: AVPlayer?
    private(set) var isObserving: Bool = false
    
    var timeObserverToken: Any?
    
    private override init() {}
    
    public var isSetup = false
    
    deinit {
        self.stopObserving()
    }
    
    var currentTime: TimeInterval {
        if let seconds = AudioPlayback.shared.player?.currentTime().seconds {
            return seconds.isNaN ? 0 : seconds
        }
        return 0
    }
    
    var currentDuration: Double {
        if let duration = AudioPlayback.shared.player?.currentItem?.asset.duration {
            return CMTimeGetSeconds(duration)
        }
        return 0
    }
    
    func play() {
        guard let player = AudioPlayback.shared.player else { return }
        player.play()
        setNowPlayingInfo()
        NotificationCenter.default.post(name: .didReceiveAudioEvent, object: self, userInfo: ["data": AudioEvent.play])
    }
    
    func pause() {
        guard let player = AudioPlayback.shared.player else { return }
        player.pause()
        NotificationCenter.default.post(name: .didReceiveAudioEvent, object: self, userInfo: ["data": AudioEvent.pause])
    }
    
    func setup(urls: [URL]) {
        if urls.count == 0 { return }
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            let asset = AVURLAsset(url: urls.first!, options: nil)
            player = AVPlayer.init(playerItem: AVPlayerItem(asset: asset))
            
            startObserving()
            
            player?.allowsExternalPlayback = true
            player?.volume = 1.0
            
            if #available(iOS 9.1, *) {
                MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
                MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
                    guard let position = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
                    let time = CMTime(seconds: position.positionTime, preferredTimescale: CMTimeScale(1000))
                    AudioPlayback.shared.player?.seek(to: time)
                    return .success
                }
            }
            
            MPRemoteCommandCenter.shared().pauseCommand.addTarget { MPRemoteCommandEvent in
                self.pause()
                return .success
            }
            
            MPRemoteCommandCenter.shared().playCommand.addTarget { MPRemoteCommandEvent in
                AudioPlayback.shared.player?.play()
                NotificationCenter.default.post(name: .didReceiveAudioEvent, object: self, userInfo: ["data": AudioEvent.play])
                return .success
            }
            
            MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
            MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [30]
            MPRemoteCommandCenter.shared().skipForwardCommand.addTarget { MPRemoteCommandEvent in
                AudioPlayback.shared.player?.seek(to: CMTimeMakeWithSeconds(self.currentTime + 30, preferredTimescale: 1000), completionHandler: { _ in
                    self.setNowPlayingInfo()
                })
                return .success
            }
            
            MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
            MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [15]
            MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget { MPRemoteCommandEvent in
                AudioPlayback.shared.player?.seek(to: CMTimeMakeWithSeconds(self.currentTime - 15, preferredTimescale: 1000), completionHandler: { _ in
                    self.setNowPlayingInfo()
                })
                return .success
            }
            
            self.isSetup = true
        } catch {
            print("error occurred")
        }
    }
    
    
    func startObserving() {
        guard let player = AudioPlayback.shared.player else {
            return
        }
        
        self.stopObserving()
        self.isObserving = true
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: &AudioPlayback.context)
        player.addObserver(self, forKeyPath: "rate", options: [], context: &AudioPlayback.context)
//        if #available(iOS 10.0, *) {
//            player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: &AudioPlayback.context)
//        }
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { time in
            NotificationCenter.default.post(name: .didReceiveAudioEvent, object: self, userInfo: ["data": AudioEvent.timestamp, "timestamp": time.seconds])
        }
    }
    
    func stopObserving() {
        return
        guard let player = AudioPlayback.shared.player, isObserving else {
            return
        }
        print("SSDEBUG", "stopping")
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status), context: &AudioPlayback.context)
//        if #available(iOS 10.0, *) {
//            player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: &AudioPlayback.context)
//        }
        self.isObserving = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &AudioPlayback.context, let observedKeyPath = keyPath else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch observedKeyPath {
        
        case "rate":
            setNowPlayingInfo()
            NotificationCenter.default.post(name: .didReceiveAudioEvent, object: self, userInfo: ["data": AudioEvent.duration, "duration": AudioPlayback.shared.player?.currentItem?.duration.seconds ?? 0])
            break
        
        case #keyPath(AVPlayer.status):
            self.handleStatusChange(change)
            
        default:
            break
            
        }
    }
    
    private func handleStatusChange(_ change: [NSKeyValueChangeKey: Any]?) {
        let status: AVPlayer.Status
        
        if let statusNumber = change?[.newKey] as? NSNumber {
            status = AVPlayer.Status(rawValue: statusNumber.intValue)!
        }
        else {
            status = .unknown
        }
        
        switch status {
        case .readyToPlay:
            NotificationCenter.default.post(name: .didReceiveAudioEvent, object: self, userInfo: ["data": AudioEvent.duration, "duration": AudioPlayback.shared.player?.currentItem?.duration.seconds ?? 0])
        case .unknown:
            break
        case .failed:
            break
        @unknown default:
            break
        }
        
        print("SSDEBUG", status)
    }
    
    func setNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyPlaybackDuration: self.currentDuration,
            MPMediaItemPropertyArtist: "Artist!",
            MPMediaItemPropertyTitle: "Title!",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: self.currentTime
        ]
    }
}
