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

import UIKit

class VideoPlaybackRateButton: UIButton {
    required init(playbackRate: PlaybackRate) {
        super.init(frame: .zero)
        
        setTitle(playbackRate: playbackRate)
        
        self.accessibilityIdentifier = "PlaybackSpeed"
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 18
        
        let blur: UIVisualEffectView
        
        if #available(iOS 13.0, *) {
            blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.systemThinMaterialDark))
        } else {
            blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        }
        
        blur.frame = self.bounds
        blur.layer.cornerRadius = 18
        blur.layer.opacity = 0.95
        blur.layer.masksToBounds = true
        blur.isUserInteractionEnabled = false
        self.insertSubview(blur, at: 0)
        
        blur.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: blur.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: blur.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: blur.bottomAnchor, constant: 0).isActive = true
    }
    
    func setTitle(playbackRate: PlaybackRate) {
        self.setTitle(playbackRate.label, for: .normal)
        self.setTitleColor(.baseGray2, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
