//
//  Color.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-27.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit
import Hue

extension UIColor {
    class var baseGreen: UIColor {
        return UIColor.init(hex: "#16A365")
    }
    
    class var baseSeparator: UIColor {
        return UIColor.init(hex: "#D7D7D7")
    }
    
    class var baseGray1: UIColor {
        return UIColor.init(hex: "#EFEFEF")
    }
    
    class var baseGray2: UIColor {
        return UIColor.init(hex: "#8F8E94")
    }
    
    class var baseGray3: UIColor {
        return UIColor.init(hex: "#606060")
    }
    
    class var baseGray4: UIColor {
        return UIColor.init(hex: "#383838")
    }
    
    class var baseGrayToolbar: UIColor {
        return UIColor.black
    }
    
    class var baseSuperLightBlue: UIColor {
        return UIColor.init(hex: "#F3FAF9")
    }
    
    class var facebook: UIColor {
        return UIColor.init(hex: "#3B529A")
    }
    
    class var tintColor: UIColor {
        guard let appDelegate = UIApplication.shared.delegate,
            let window = appDelegate.window,
            let tintColor = window?.tintColor else { return UIColor.baseGreen }
        return tintColor
    }
    
    class var readerWhite: UIColor {
        return UIColor.white
    }
    
    class var readerWhiteFont: UIColor {
        return UIColor.baseGray4
    }
    
    class var readerDark: UIColor {
        return UIColor.init(hex: "#292929")
    }
    
    class var readerDarkFont: UIColor {
        return UIColor.init(hex: "#CCCCCC")
    }
    
    class var readerSepia: UIColor {
        return UIColor.init(hex: "#FBF0D9")
    }
    
    class var readerSepiaFont: UIColor {
        return UIColor.init(hex: "#5b4636")
    }
    
    class var readerSeparator: UIColor {
        return UIColor(white: 0.5, alpha: 0.2)
    }
    
    class var readerNormal: UIColor {
        return UIColor(white: 0.5, alpha: 0.7)
    }
}
