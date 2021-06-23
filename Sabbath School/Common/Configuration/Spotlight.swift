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
import CoreSpotlight
import MobileCoreServices

struct Spotlight {
    static func indexQuarterly(quarterly: Quarterly, image: UIImage) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeData as String)
        attributeSet.title = quarterly.title
        attributeSet.contentDescription = quarterly.humanDate
        attributeSet.identifier = quarterly.index
        attributeSet.relatedUniqueIdentifier = quarterly.index
        attributeSet.thumbnailData = UIImage.pngData(image)()
        Spotlight.indexSpotlight(identifier: quarterly.index, attributeSet: attributeSet)
    }
    
    static func indexSpotlight(identifier: String, attributeSet: CSSearchableItemAttributeSet) {
        let item = CSSearchableItem(uniqueIdentifier: identifier, domainIdentifier: Constants.DefaultKey.spotlightDomain, attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
           if let error = error {
               print("Indexing error: \(error.localizedDescription)")
           } else {
               print("Search item successfully indexed!")
           }
        }
    }
    
    static func clearSpotlight() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [Constants.DefaultKey.spotlightDomain]) { error in
            if let error = error {
                print("Cleaning spotlight error: \(error.localizedDescription)")
            } else {
                print("Spotlight cleaned!")
            }
        }
    }
}
