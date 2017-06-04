//
//  OpenButton.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import pop

class OpenButton: ASButtonNode {
    override func sendActions(forControlEvents controlEvents: ASControlNodeEvent, with touchEvent: UIEvent?) {
        if controlEvents == .touchDown {
            let anim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            anim?.duration = 0.2
            anim?.toValue = NSValue(cgSize: CGSize(width: 0.95, height: 0.95))
            self.layer.pop_add(anim, forKey: anim?.property.name)
        }
        
        if controlEvents == .touchUpInside {
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            anim?.dynamicsTension = 300
            anim?.dynamicsFriction = 16
            anim?.dynamicsMass = 1
            anim?.velocity = NSValue(cgSize: CGSize(width: 2, height: 2))
            anim?.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
            layer.pop_add(anim, forKey: anim?.property.name)
        }
        
        if controlEvents == .touchDragOutside || controlEvents == .touchCancel {
            let anim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            anim?.duration = 0.2
            anim?.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
            self.layer.pop_add(anim, forKey: anim?.property.name)
        }
        
        super.sendActions(forControlEvents: controlEvents, with: touchEvent)
    }
}
