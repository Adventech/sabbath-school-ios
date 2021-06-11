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

import Foundation
import LinkPresentation

@available(iOS 13.0, *)
class ShareItem: NSObject, UIActivityItemSource {
    let title: String
    let subtitle: String
    let url: URL
    let image: UIImage
    let text: String
    
    convenience init(title: String, subtitle: String, url: URL, image: UIImage) {
        self.init(title: title, subtitle: subtitle, url: url, image: image, text: "")
    }
    
    init(title: String, subtitle: String, url: URL, image: UIImage, text: String) {
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.image = image
        self.text = text
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        self.text.isEmpty ? self.url : self.text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        self.text.isEmpty ? self.url : self.text
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        
        metadata.title = self.title
        metadata.iconProvider = NSItemProvider(object: image)
        metadata.imageProvider = NSItemProvider(object: image)
        metadata.originalURL = URL(fileURLWithPath: self.subtitle)
        metadata.url = self.url
        
        return metadata
    }
}
