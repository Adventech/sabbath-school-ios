//
//  Navigation.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        if let lastViewController = self.viewControllers.last {
//            return lastViewController.preferredStatusBarStyle
//        }
//        
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    func setBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.iconNavbarBack(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(popBack))
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
    }
    
    func setCloseButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.iconNavbarClose(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss as (Void) -> Void))
    }
    
    func popBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func dismiss(completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                completion?()
            })
        }
    }

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

    func setTransparentNavigation() {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar?.hideBottomHairline()
        navBar?.isTranslucent = true
    }
    
    func setTranslucentNavigation(_ translucent: Bool = true, color: UIColor, tintColor: UIColor = UIColor.white, titleColor: UIColor = UIColor.black, andFont font: UIFont = R.font.latoBold(size: 15)!) {
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
