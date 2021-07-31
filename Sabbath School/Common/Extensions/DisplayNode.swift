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

import AsyncDisplayKit

private var shimmeringNodeKey: UInt = 1

extension ASDisplayNode {
    var shimmeringNode: ShimmeringNode? {
        get {
            return objc_getAssociatedObject(self, &shimmeringNodeKey) as? ShimmeringNode
        }
        set(newValue) {
            objc_setAssociatedObject(self, &shimmeringNodeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func addShimmerToNode(node: ASDisplayNode) {
        if node.shimmeringNode == nil {
            let frame = node.frame
            node.shimmeringNode = ShimmeringNode(didLoadBlock: { shimmeringNode in
                shimmeringNode.view.shimmeringSpeed = frame.size.width
                shimmeringNode.view.shimmeringPauseDuration = 0.1
                shimmeringNode.view.isShimmering = true
            })
            node.shimmeringNode?.frame = frame
            node.shimmeringNode?.contentNode = node
            addSubnode(node.shimmeringNode!)
        }
    }
    
    func gradient(from color1: UIColor, to color2: UIColor) {
        if color1 == color2 { return }
        DispatchQueue.main.async {
            let size = self.view.frame.size
            let width = size.width
            let height = size.height

            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [color1.cgColor, color2.cgColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: width/2, y: 0.0)
            gradient.endPoint = CGPoint(x: width/2, y: 1.0)
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            self.view.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    func gradientBlur(from color1: UIColor, to color2: UIColor) {
        if color1 == color2 { return }
        DispatchQueue.main.async {
            let size = self.view.frame.size
            let width = size.width
            let height = size.height

            let viewEffect = UIBlurEffect(style: .light)
            let effectView = UIVisualEffectView(effect: viewEffect)
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.locations = [0.0, 0.6, 0.75]
            gradient.colors = [color1.cgColor, color2.cgColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.75)
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            
            effectView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            
            if #available(iOS 11.0, *) {
                effectView.layer.mask = gradient
            } else {
                let maskView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
                maskView.backgroundColor = UIColor.white
                maskView.layer.mask = gradient
                effectView.mask = maskView
            }
            
            effectView.isUserInteractionEnabled = false
            
            self.view.insertSubview(effectView, at: 0)
        }
    }
}


// Implementation from https://stackoverflow.com/a/47114246
class GradientNode: ASDisplayNode {
    private let startUnitPoint: CGPoint
    private let endUnitPoint: CGPoint
    private let colors: [UIColor]
    private let locations: [CGFloat]?

    override class func draw(_ bounds: CGRect, withParameters parameters: Any?, isCancelled isCancelledBlock: () -> Bool, isRasterizing: Bool) {
        guard let parameters = parameters as? GradientNode else {
            return
        }

        // Calculate the start and end points
        let startUnitX = parameters.startUnitPoint.x
        let startUnitY = parameters.startUnitPoint.y
        let endUnitX = parameters.endUnitPoint.x
        let endUnitY = parameters.endUnitPoint.y

        let startPoint = CGPoint(x: bounds.width * startUnitX + bounds.minX, y: bounds.height * startUnitY + bounds.minY)
        let endPoint = CGPoint(x: bounds.width * endUnitX + bounds.minX, y: bounds.height * endUnitY + bounds.minY)

        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.clip(to: bounds)

        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: parameters.colors.map { $0.cgColor } as CFArray,
                                        locations: parameters.locations) else {
            return
        }

        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: CGGradientDrawingOptions.drawsAfterEndLocation)
        
        
        context.restoreGState()
    }

    init(startingAt startUnitPoint: CGPoint, endingAt endUnitPoint: CGPoint, with colors: [UIColor], for locations: [CGFloat]? = nil) {
        self.startUnitPoint = startUnitPoint
        self.endUnitPoint = endUnitPoint
        self.colors = colors
        self.locations = locations

        super.init()
    }

    override func drawParameters(forAsyncLayer layer: _ASDisplayLayer) -> NSObjectProtocol? {
        return self
    }
}
