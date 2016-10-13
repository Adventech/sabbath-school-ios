//
//  Navigation.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 27/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
extension UINavigationController {
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        if let rootViewController = self.viewControllers.first {
            return rootViewController.preferredStatusBarStyle
        }
        return self.preferredStatusBarStyle
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return visibleViewController!.supportedInterfaceOrientations
    }
    
    open override var shouldAutorotate : Bool {
        return visibleViewController!.shouldAutorotate
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    
    func setBackButtom() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.iconNavbarBack(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(popBack))
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
    }
    
    func popBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Bounce with color
    
    func bounceTopWithColor(_ color: UIColor, belowView: UIView?) {
        // Bounce with color
        let size = 1000 as CGFloat
        let topView = UIView(frame: CGRect(x: 0, y: -size, width: view.frame.width, height: size))
        topView.autoresizingMask = .flexibleWidth
        topView.backgroundColor = color
        
        if let below = belowView {
            view.insertSubview(topView, belowSubview: below)
        } else {
            view.addSubview(topView)
        }
    }
    
    // MARK: - NavigationBar
    
    func setTransparentNavigation() {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar?.hideBottomHairline()
        navBar?.isTranslucent = true
    }
    
    func setTranslucentNavigation(_ translucent: Bool = true, color: UIColor, tintColor: UIColor = UIColor.white, titleColor: UIColor = UIColor.black, andFont font: UIFont = UIFont.systemFont(ofSize: 17)) {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage.imageWithColor(color), for: UIBarMetrics.default)
        navBar?.showBottomHairline()
        navBar?.isTranslucent = translucent
        navBar?.tintColor = tintColor
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName: titleColor, NSFontAttributeName: font]
    }
    
    func setNavigationBarColor(color: UIColor) {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage.imageWithColor(color), for: UIBarMetrics.default)
        navBar?.showBottomHairline()
        navBar?.isTranslucent = false
    }
    
    // MARK: - Orientation
    
    public func setOrientationToRotate(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = false
    }
    
    fileprivate func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView? {
        if view.isKind(of: UIImageView.self) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews )
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
}
