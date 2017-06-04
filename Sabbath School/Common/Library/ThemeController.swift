//
//  ThemeController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ThemeController: ASViewController<ASDisplayNode> {
    var colorPrimary: UIColor? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func colorize() {
        if colorPrimary != nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.tintColor = colorPrimary!
            setTranslucentNavigation(true, color: colorPrimary!, tintColor: .white, titleColor: .white)
        }
    }
}
