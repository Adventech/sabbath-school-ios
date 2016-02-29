//
//  Font.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 27/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

extension UIFont {
    
    // MARK: - Lato font
    
    class func latoItalicOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Italic", size: size)!
    }
    
    class func latoRegularOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Regular", size: size)!
    }
    
    class func latoMediumOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Medium", size: size)!
    }
    
    class func latoMediumItalicOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-MediumItalic", size: size)!
    }
    
    class func latoBoldOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Bold", size: size)!
    }
    
    class func latoBoldItalicOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-BoldItalic", size: size)!
    }
}
