//
//  ScrollView.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 22/02/22.
//  Copyright © 2022 Adventech. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func scrollToTop(animated: Bool) {
        var offset = CGPoint(x: -self.contentInset.left, y: -self.contentInset.top)

        if #available(iOS 11.0, *) {
            offset = CGPoint(x: -self.adjustedContentInset.left, y: -self.adjustedContentInset.top)
        }

        self.setContentOffset(offset, animated: true)
    }
}
