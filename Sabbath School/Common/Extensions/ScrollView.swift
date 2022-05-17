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
        let offset = CGPoint(x: -self.adjustedContentInset.left, y: -self.adjustedContentInset.top)

        self.setContentOffset(offset, animated: true)
    }
}
