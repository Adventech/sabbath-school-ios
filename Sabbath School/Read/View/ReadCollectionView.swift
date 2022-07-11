/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

class ReadCollectionView: ASDisplayNode {
    let collectionNode = ASPagerNode()
    let miniPlayerView = AudioMiniPlayerView()
    var miniPlayerShown = false
    var bottomPadding: CGFloat = 20

    override init() {
        super.init()
        
        let currentTheme = Preferences.currentTheme()
        backgroundColor = currentTheme.backgroundColor
        
        collectionNode.backgroundColor = AppStyle.Base.Color.background
        collectionNode.allowsAutomaticInsetsAdjustment = true
        collectionNode.autoresizesSubviews = true
        collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        collectionNode.automaticallyRelayoutOnSafeAreaChanges = true
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow
            if let bottomPadding = window?.safeAreaInsets.bottom, bottomPadding > 0 {
                self.bottomPadding = bottomPadding
            }
        }
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let relativeSpec = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: miniPlayerShown ? bottomPadding : -400, right: 0),
            child: ASRelativeLayoutSpec(horizontalPosition: .center,
                                        verticalPosition: .end,
                                        sizingOption: [],
                                        child: miniPlayerView))
        
        let backgroundSpec = ASBackgroundLayoutSpec(
            child: relativeSpec,
            background: ASInsetLayoutSpec(
                insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                child: collectionNode
            )
        )
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: backgroundSpec)
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.collectionNode.frame = context.finalFrame(for: self.collectionNode)
                self.miniPlayerView.frame = context.finalFrame(for: self.miniPlayerView)
                self.layoutIfNeeded()
            },
            completion: { finished in
                context.completeTransition(finished)
            }
        )
    }
}
