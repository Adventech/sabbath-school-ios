//
//  ImageLoader.swift
//  SabbathSchoolTV
//
//  Created by Emerson Carpes on 29/10/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import Combine
import SwiftUI
import SDWebImageSwiftUI

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<UIImage, Never>()
    
    var data = UIImage() {
        didSet {
            didChange.send(data)
        }
    }
    
    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let cache = SDImageCache(namespace: "ssacache")
        
        SDWebImageManager(cache: cache, loader: SDImageLoadersManager.shared).loadImage(with: url, progress: nil) { image, _, _, _, _, _ in
            if let image {
                self.data = image
            } else {
                // TODO: handle loading image error here
            }
        }
    }
}
