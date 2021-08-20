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
import SwiftAudio

enum AudioRate {
    case slow
    case normal
    case fast
    case fastest
    
    var val: Float {
        switch self {
        case .slow: return 0.75
        case .normal: return 1
        case .fast: return 1.5
        case .fastest: return 2
        }
    }
    
    var label: String {
        switch self {
        case .slow: return "¾×"
        case .normal: return "1×"
        case .fast: return "1½×"
        case .fastest: return "2×"
        }
    }
}

class AudioPlayback: NSObject {
    static let shared = QueuedAudioPlayer()
    static var rate: AudioRate = .normal
    static var lessonIndex: String? = nil
    
    private override init() {}
    
    static func configure() {
        try? AVAudioSession.sharedInstance().setMode(.default)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        AudioPlayback.shared.remoteCommands = [
            .play,
            .pause,
            .next,
            .skipForward(preferredIntervals: [30]),
            .skipBackward(preferredIntervals: [15]),
            .changePlaybackPosition
        ]
    }
    
    static func play() {
        if AudioPlayback.shared.nextItems.count == 0 && AudioPlayback.shared.currentTime == AudioPlayback.shared.duration {
            AudioPlayback.shared.seek(to: 0)
        }
        AudioPlayback.shared.play()
    }
    
    static func pause() {
        AudioPlayback.shared.pause()
    }
}
