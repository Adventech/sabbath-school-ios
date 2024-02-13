/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
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
import AsyncDisplayKit

extension ASDKNavigationController {
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController?.childForStatusBarStyle ?? topViewController
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }

    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? false
    }

    // MARK: Fix the broken back gesture when using custom back button
    // http://stackoverflow.com/a/38532720/517707

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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.iconNavbarBack(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(popBack))
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
    }

    func setCloseButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.iconNavbarClose(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismiss as () -> Void))
    }

    @objc func popBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @objc func dismiss() {
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
        navBar?.isTranslucent = translucent
        navBar?.tintColor = tintColor
        navBar?.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: font
        ]
    }

    func setNavigationBarColor(color: UIColor) {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage.imageWithColor(color), for: UIBarMetrics.default)
        navBar?.isTranslucent = false
    }

    public func setOrientationToRotate(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
    func setNavigationBarOpacity(alpha: CGFloat) {
        let navigationBackgroundView = self.navigationController?.navigationBar.subviews.first
        navigationBackgroundView?.alpha = alpha
    }
}

extension UINavigationBar {
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView?.isHidden = true
    }

    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        if (navigationBarImageView != nil) {
            navigationBarImageView!.isHidden = false
        }
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

// MARK: - Fix iOS 9 crash https://stackoverflow.com/a/32010520/517707

extension UIAlertController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    open override var shouldAutorotate: Bool {
        return false
    }
}

extension UIWindow {
    open override var tintColor: UIColor! {
        didSet {
            Preferences.userDefaults.set(tintColor.hex(), forKey: Constants.DefaultKey.tintColor)
        }
    }
}
