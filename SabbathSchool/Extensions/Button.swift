//
//  Button.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 02/12/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

extension UIButton {
    
    /**
     Add a space between the text and image
     http://stackoverflow.com/a/25559946/517707
     */
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
    
    
    /**
     Invert image position
     http://stackoverflow.com/a/32174204/517707
     */
    func imageOnRight() {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
}
