//
//  PopupTransitionAnimation.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit
import pop

enum PopupStyle {
    case arrow
    case square
}

@objc
protocol PopupTransitionAnimatorDelegate: NSObjectProtocol {
    /*
     Called on the delegate when the user has taken action to dismiss the popup.
     */
    @objc optional func popupWillDismiss(popup: PopupTransitionAnimator)
    
    /*
     Called on the delegate when the dismiss action block did finished.
     */
    @objc optional func popupDidDismiss(popup: PopupTransitionAnimator)
}

class PopupTransitionAnimator: NSObject, UIGestureRecognizerDelegate {
    weak var delegate: PopupTransitionAnimatorDelegate?
    var style: PopupStyle = .arrow
    var overlayColor: UIColor = UIColor(white: 0, alpha: 0.6)
    var cornerRadius: CGFloat = 4
    var spaceFromRect: CGFloat = 10
    var spaceFromSide: CGFloat = 5
    var targetRect: CGRect = CGRect.zero
    var fromView: UIView! {
        didSet { targetRect = fromView.convert(fromView.bounds, to: containerView) }
    }
    var interactive: Bool = true
    var contentSize: CGSize = CGSize.zero
    var arrowWidth: CGFloat = 12
    var arrowHeight: CGFloat = 8
    var arrowColor: UIColor?
    var contentScrollView: UIScrollView?
    
    fileprivate var arrowView: ArrowView!
    fileprivate var modalController: UIViewController!
    fileprivate var containerView: UIView!
    fileprivate var wrapperView: UIView!
    fileprivate var presentFromTop: Bool = true
    fileprivate var shouldCompleteTransition = false
    fileprivate var transitionInProgress = false
    fileprivate var initialOrigin: CGRect!
    fileprivate var keyboardVisible: Bool = false
    
    // MARK: Init
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(sender:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(sender:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Keyboard Observe
    
    func keyboardDidShow(sender: NSNotification) {
        keyboardVisible = true
    }
    
    func keyboardDidHide(sender: NSNotification) {
        keyboardVisible = false
    }
    
    //
    
    func updateArrowColor(color: UIColor, animated: Bool = false, duration: TimeInterval = 0.4) {
        arrowView.arrowColor = color
        arrowView.setNeedsDisplay()
        UIView.transition(with: arrowView, duration: duration, options: .transitionCrossDissolve, animations: {
            self.arrowView.layer.displayIfNeeded()
        }, completion: nil)
    }
    
    // MARK: Gestures
    
    fileprivate func prepareGestureRecognizerInView(view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:)))
        panGesture.delegate = self
        //        panGesture.scrollView = contentScrollView
        view.addGestureRecognizer(panGesture)
    }
    
    func didPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        
        switch gesture.state {
        case .began:
            transitionInProgress = true
            break
        case .changed:
            let offsetMax: CGFloat = 80
            let inputSensitivity: CGFloat = 200
            let movingRange = offsetMax * tanh(translation.y / inputSensitivity)
            
            shouldCompleteTransition = movingRange > offsetMax/2 || -movingRange > offsetMax/2
            let const = movingRange > 0 ? movingRange*1/offsetMax : -movingRange*1/offsetMax
            let percentage = CGFloat(fminf(fmaxf(Float(const), 0.0), 1.0))
            
            // Move view
            var modifiedOrigin = initialOrigin.origin
            modifiedOrigin.y += movingRange
            wrapperView.frame.origin = modifiedOrigin
            containerView.alpha = 1-(percentage*0.5)
            break
        case .cancelled, .ended:
            transitionInProgress = false
            
            if shouldCompleteTransition {
                dismissModal()
            } else {
                let positionYAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                positionYAnimation?.toValue = initialOrigin.midY
                positionYAnimation?.springBounciness = 10
                positionYAnimation?.velocity = velocity.y
                wrapperView.layer.pop_add(positionYAnimation, forKey: "positionYAnimation")
                
                let overlayAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                overlayAnimation?.toValue = 1
                containerView.layer.pop_add(overlayAnimation, forKey: "blockAnimation")
            }
            break
        default:
            print("Swift switch must be exhaustive, thus the default")
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            if let view = touch.view, view.isDescendant(of: wrapperView) {
                return false
            }
        }
        return true
    }
    
    // MARK: Dismiss
    
    func dismissModal() {
        if keyboardVisible {
            wrapperView.endEditing(true)
        } else {
            delegate?.popupWillDismiss?(popup: self)
            
            modalController.dismiss(animated: true, completion: {
                self.delegate?.popupDidDismiss?(popup: self)
            })
        }
    }
    
    // MARK: Complementary functions
    
    func bestXPosition() -> CGFloat {
        var halfRect = targetRect.origin.x + (targetRect.width/2)
        let halfModal = contentSize.width/2
        let halfScreen = containerView.frame.width/2
        let leftToRight = halfRect < halfScreen
        
        if style == .square {
            return halfScreen-halfModal
        }
        
        // Define rect calc direction
        halfRect = leftToRight ? halfRect : containerView.frame.width - halfRect
        
        
        // Center on screen
        if contentSize.width >= containerView.frame.width {
            return containerView.center.x-halfModal
        }
        
        // Center on Rect
        if halfRect > halfModal {
            return halfRect-halfModal
        }
        
        // Left or Right align
        if leftToRight {
            return spaceFromSide
        } else {
            return containerView.frame.width - contentSize.width - spaceFromSide
        }
    }
    
    // MARK: Draw arrow view
    
    class ArrowView: UIView {
        var arrowColor: UIColor!
        
        init(frame: CGRect, rotated: Bool, backgroundColor: UIColor) {
            super.init(frame: frame)
            self.arrowColor = backgroundColor
            self.backgroundColor = UIColor.clear
            if rotated {
                self.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let polygonPath = UIBezierPath()
            polygonPath.move(to: CGPoint(x: rect.width/2, y: 0))
            polygonPath.addLine(to: CGPoint(x: rect.width, y: rect.height))
            polygonPath.addLine(to: CGPoint(x: 0, y: rect.height))
            polygonPath.close()
            arrowColor.setFill()
            polygonPath.fill()
        }
    }
}

extension PopupTransitionAnimator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension PopupTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        guard let toView = toController.view else { return }
        containerView = transitionContext.containerView
        presentFromTop = targetRect.origin.y < containerView.bounds.height/2
        contentSize = toController.preferredContentSize
        
        let isUnwinding = toController.presentedViewController == fromController
        let isPresenting = !isUnwinding
        
        // Tap gesture on container to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PopupTransitionAnimator.dismissModal))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        containerView.addGestureRecognizer(tapGesture)
        
        // Defines the presentation origin
        var positionY: CGFloat!
        var positionX: CGFloat!
        
        if style == .arrow {
            positionX = targetRect.origin.x + (targetRect.size.width/2)
            
            if presentFromTop {
                positionY = targetRect.origin.y + targetRect.height + spaceFromRect + arrowHeight
            } else {
                positionY = targetRect.origin.y - contentSize.height - spaceFromRect - arrowHeight
            }
        }
        
        if style == .square {
            positionY = containerView.center.y - (contentSize.height/2)
            positionX = containerView.center.x
        }
        
        // Check if presenting or dismissing
        if isPresenting {
            modalController = toController
            wrapperView = UIView(frame: CGRect(x: bestXPosition(), y: positionY, width: contentSize.width, height: contentSize.height))
            wrapperView.alpha = 0
            
            toView.frame = CGRect(x: 0, y: 0, width: wrapperView.frame.width, height: wrapperView.frame.height)
            toView.layer.cornerRadius = cornerRadius
            toView.clipsToBounds = true
            wrapperView.addSubview(toView)
            containerView.addSubview(wrapperView)
            
            initialOrigin = wrapperView.frame
            
            // Pan gesture
            if interactive {
                prepareGestureRecognizerInView(view: toView)
            }
            
            // Arrow
            if style == .arrow {
                if arrowColor == nil {
                    if let backgroundColor = toView.backgroundColor {
                        arrowColor = backgroundColor
                    } else {
                        arrowColor = UIColor.white
                    }
                }
                
                let arrowYpos = presentFromTop ? -arrowHeight+1 : contentSize.height-1
                var arrowFrame = CGRect(x: positionX-(arrowWidth/2), y: arrowYpos, width: arrowWidth, height: arrowHeight)
                arrowView = ArrowView(frame: arrowFrame, rotated: !presentFromTop, backgroundColor: arrowColor!)
                
                // Adjust arrow frame
                arrowFrame = arrowView.convert(arrowView.bounds, to: wrapperView)
                arrowFrame.origin.y = arrowYpos
                arrowView.frame = arrowFrame
                
                wrapperView.addSubview(arrowView)
            }
            
            // Container
            let overlayAnimation = POPBasicAnimation(propertyNamed: kPOPLayerBackgroundColor)
            overlayAnimation?.toValue = overlayColor
            containerView.layer.pop_add(overlayAnimation, forKey: "overlayAnimation")
            
            // Modal Animations
            let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
            alphaAnimation?.toValue = 1
            wrapperView.layer.pop_add(alphaAnimation, forKey: "alphaAnimation")
            
            if style == .arrow {
                let positionYAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                positionYAnimation?.fromValue = presentFromTop ? positionY : positionY+contentSize.height
                positionYAnimation?.springBounciness = 8
                wrapperView.layer.pop_add(positionYAnimation, forKey: "positionYAnimation")
            }
            
            let positionXAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
            positionXAnimation?.fromValue = positionX
            positionXAnimation?.springBounciness = 8
            wrapperView.layer.pop_add(positionXAnimation, forKey: "positionXAnimation")
            
            let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            scaleAnimation?.springBounciness = 8
            scaleAnimation?.fromValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
            wrapperView.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        } else {
            
            // Container
            let overlayAnimation = POPBasicAnimation(propertyNamed: kPOPLayerBackgroundColor)
            overlayAnimation?.toValue = UIColor.clear
            containerView.layer.pop_add(overlayAnimation, forKey: "overlayAnimation")
            
            // Modal Animations
            let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
            alphaAnimation?.toValue = 0
            alphaAnimation?.completionBlock = {(animation, finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            wrapperView.layer.pop_add(alphaAnimation, forKey: "alphaAnimation")
            
            if style == .arrow {
                let positionYAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                positionYAnimation?.toValue = presentFromTop ? positionY : positionY+contentSize.height
                positionYAnimation?.springBounciness = 5
                wrapperView.layer.pop_add(positionYAnimation, forKey: "positionYAnimation")
                
                arrowColor = nil
            }
            
            let positionXAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
            positionXAnimation?.toValue = positionX
            positionXAnimation?.springBounciness = 5
            wrapperView.layer.pop_add(positionXAnimation, forKey: "positionXAnimation")
            
            let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            scaleAnimation?.springBounciness = 5
            scaleAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
            wrapperView.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
        }
    }
}
