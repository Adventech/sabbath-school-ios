/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

import AsyncDisplayKit

class CompositeScrollViewController: ASDKViewController<ASDisplayNode>, ASTableDelegate {
    private var scrollReachedTouchpoint: Bool = false
    private var everScrolled: Bool = false
    
    var navbarTitle: String {
        fatalError("Must Override this")
    }
    
    // ??
    var mn: CGFloat {
        return 0
    }
    
    // Offset from touch point
    var touchpointOffset: CGFloat {
        return 50
    }
    
    // Rect of the target touchpoint at which the navigation bar would change its appearance
    var touchpointRect: CGRect? {
        return nil
    }
    
    var parallaxEnabled: Bool {
        return false
    }
    
    var parallaxImageHeight: CGFloat? {
        return 0
    }
    
    var parallaxTargetRect: CGRect? {
        fatalError("Must Override this")
    }
    
    var parallaxHeaderNode: ASCellNode? {
        fatalError("Must Override this")
    }
    
    var parallaxHeaderCell: UITableViewCell? {
        fatalError("Must Override this")
    }
    
    var tintColors: (fromColor: UIColor, toColor: UIColor) {
        return (.white, AppStyle.Base.Color.navigationTint)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationbar()
        scrollBehavior()
        
//        view.backgroundColor = .white | .black
//        navigationController?.navigationBar.prefersLargeTitles = false
//        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationbar()
        scrollBehavior()
    }
    
    func scrollBehavior() {
        guard let touchpointRect = self.touchpointRect else { return }
        guard let navigationBarMaxY = self.navigationController?.navigationBar.rectCorrespondingToWindow.maxY else { return }

        var navBarAlpha: CGFloat = (touchpointOffset - (touchpointRect.minY + mn - navigationBarMaxY)) / touchpointOffset
        var navBarTitleAlpha: CGFloat = touchpointRect.minY-mn < navigationBarMaxY ? 1 : 0
        
        if touchpointRect.minY == 0 {
            navBarAlpha = everScrolled ? 1 : 0
            navBarTitleAlpha = everScrolled ? 1 : 0
        }
        
        setNavigationBarOpacity(alpha: navBarAlpha)
        
        title = navBarAlpha < 1 ? "" : self.navbarTitle
        
        statusBarUpdate(light: navBarTitleAlpha != 1)
        scrollReachedTouchpoint = navBarTitleAlpha == 1
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.transitionColor(fromColor: UIColor.white.withAlphaComponent(navBarAlpha), toColor: AppStyle.Base.Color.navigationTitle, progress:navBarAlpha)]
            
        self.navigationController?.navigationBar.tintColor =
            UIColor.transitionColor(fromColor: tintColors.fromColor, toColor: tintColors.toColor, progress:navBarAlpha)
    }
    
    func setupNavigationbar() {
        setNavigationBarOpacity(alpha: 0)
        self.navigationController?.navigationBar.hideBottomHairline()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle.withAlphaComponent(0)]
        self.navigationController?.navigationBar.barTintColor = nil
        setBackButton()
    }
    
    func statusBarUpdate(light: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    func scrollViewDidScrollCallback(_ scrollView: UIScrollView) {
        everScrolled = true
        scrollBehavior()
        parallax(scrollView)
    }
    
    func parallax(_ scrollView: UIScrollView) {
        if !parallaxEnabled { return }

        guard let parallaxHeaderNode = self.parallaxHeaderNode else { return }
        guard let parallaxHeaderCell = self.parallaxHeaderCell else { return }
        guard let parallaxImageHeight = self.parallaxImageHeight else { return }
        guard var parallaxTargetRect = self.parallaxTargetRect else { return }
        
        let scrollOffset = scrollView.contentOffset.y
        
        if scrollOffset >= 0 {
            parallaxTargetRect.origin.y = scrollOffset / 2
        } else {
            parallaxHeaderCell.frame.origin.y = scrollOffset
            parallaxHeaderCell.frame.size.height = parallaxImageHeight + (-scrollOffset)
            parallaxHeaderNode.frame.size.height = parallaxImageHeight + (-scrollOffset)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollCallback(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidScrollCallback(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidScrollCallback(scrollView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return scrollReachedTouchpoint ? .default : .lightContent
    }
}
