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
import AVKit
import SwiftAudio
import MediaPlayer

class VideoPlayback: NSObject {
    static let shared = VideoPlayback()
    let controller = VideoPlaybackPlayerViewController()
    var pip: Bool = false
    private override init() {}
    
    func stop() {
        if !VideoPlayback.shared.pip && !VideoPlayback.shared.controller.shown {
            VideoPlayback.shared.controller.player?.pause()
            VideoPlayback.shared.controller.player = nil
        }
    }
}

class VideoPlaybackPlayerViewController: AVPlayerViewController {
    var shown: Bool = false
    var playbackSpeedButton = VideoPlaybackRateButton(playbackRate: .normal)
    
    private func findPlayPauseButton(view: UIView) -> UIView? {
        if view.accessibilityIdentifier == "Mute Toggle" {
            return view
        }
        
        for subview in view.subviews {
            if let result = findPlayPauseButton(view: subview) {
                return result
            }
        }
        return nil
    }
    
    func addRateButton() {
        if let playerView = self.view,
           let playPauseButton = findPlayPauseButton(view: playerView),
           let playerControlsView = playPauseButton.superview {
            playerControlsView.addSubview(playbackSpeedButton)
            NSLayoutConstraint.activate([
                playbackSpeedButton.heightAnchor.constraint(equalTo: playPauseButton.heightAnchor),
                playbackSpeedButton.widthAnchor.constraint(equalTo: playPauseButton.widthAnchor),
                playbackSpeedButton.leadingAnchor.constraint(equalTo: playPauseButton.leadingAnchor),
                playbackSpeedButton.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 10),
            ])
        }
        
        playbackSpeedButton.addTarget(self, action: #selector(self.playbackSpeedButtonTapped), for: .touchUpInside)
    }
    
    @objc func playbackSpeedButtonTapped(sender: VideoPlaybackRateButton) {
        self.player?.rate = sender.playbackRate.val
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addRateButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.shown = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.shown = false
        VideoPlayback.shared.stop()
    }
}

class VideoPlaybackDelegatable: ASDKViewController<ASDisplayNode> {
    func playVideo(video: Video, artwork: UIImage? = nil) {
        let titleMetadata = AVMutableMetadataItem()
        titleMetadata.identifier = AVMetadataIdentifier.commonIdentifierTitle
        titleMetadata.value = video.title as NSString
        
        let artistMetadata = AVMutableMetadataItem()
        artistMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtist
        artistMetadata.value = video.artist as NSString
        
        var items = [titleMetadata, artistMetadata]
        
        if let artwork = artwork {
            let artworkMetadata = AVMutableMetadataItem()
            artworkMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtwork
            artworkMetadata.value = artwork.pngData() as (NSCopying & NSObjectProtocol)?
            items.append(artworkMetadata)
        }
        
        let pi = AVPlayerItem(asset: AVAsset(url: video.src))
        
        if #available(iOS 12.2, *) {
            pi.externalMetadata = items
        }
        
        let player = AVPlayer(playerItem: pi)
        VideoPlayback.shared.controller.player = player
        
        if VideoPlayback.shared.pip {
            player.play()
        } else {
            self.present(VideoPlayback.shared.controller, animated: true) {
                player.play()
            }
        }
    }

    func restoreFromPictureInPicture(playerViewController: UIViewController, completionHandler: @escaping (Bool) -> Void) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [self] in
                self.present(playerViewController, animated: true) {
                    completionHandler(true)
                }
            }
        } else {
            present(playerViewController, animated: false) {
                completionHandler(true)
            }
        }
    }
}

extension VideoPlaybackDelegatable: AVPlayerViewControllerDelegate {
    public func playerViewControllerDidStartPictureInPicture(_ playerViewController2: AVPlayerViewController) {
        VideoPlayback.shared.pip = true
    }
    
    public func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        VideoPlayback.shared.pip = false
        VideoPlayback.shared.stop()
    }
    
    public func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return true
    }

    public func playerViewController(_ playerViewController: AVPlayerViewController,
                              restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        restoreFromPictureInPicture(playerViewController: playerViewController, completionHandler: completionHandler)
    }
}
