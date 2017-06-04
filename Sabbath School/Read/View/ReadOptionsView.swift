//
//  ReadOptionsView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-03.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class ReadOptionsView: ASDisplayNode {
    let themeNode = ASDisplayNode { UISegmentedControl(frame: CGRect.zero) }
    var themeView: UISegmentedControl { return themeNode.view as! UISegmentedControl }
    
    let typefaceNode = ASDisplayNode { UISegmentedControl(frame: CGRect.zero) }
    var typefaceView: UISegmentedControl { return typefaceNode.view as! UISegmentedControl }
    
    let fontSizeNode = ASDisplayNode {
        DiscreteSlider(frame: CGRect(x: 0, y: 0, width: 375, height: 55))
    }
    var fontSizeView: DiscreteSlider { return fontSizeNode.view as! DiscreteSlider }
    let fontSizeSmallNode = ASImageNode()
    let fontSizeLargeNode = ASImageNode()
    
    let dividerNode1 = ASDisplayNode()
    let dividerNode2 = ASDisplayNode()
    
    override init() {
        super.init()
        
        backgroundColor = .white
        
        let lightThemeButton = segmentButtonProvider(text: "Light", font: R.font.latoRegular(size: 16)!, selected: true)
        let darkThemeButton = segmentButtonProvider(text: "Dark", font: R.font.latoRegular(size: 16)!, selected: false)
        let sepiaThemeButton = segmentButtonProvider(text: "Sepia", font: R.font.latoRegular(size: 16)!, selected: false)
        
        themeView.insertSegment(with: lightThemeButton, at: 0, animated: false)
        themeView.insertSegment(with: sepiaThemeButton, at: 1, animated: false)
        themeView.insertSegment(with: darkThemeButton, at: 2, animated: false)
        themeView.removeBorders()
        
        let andadaTypefaceButton = segmentButtonProvider(text: "Andada", font: R.font.loraRegular(size: 16)!, selected: true)
        let latoTypefaceButton = segmentButtonProvider(text: "Lato", font: R.font.latoRegular(size: 16)!, selected: false)
        let ptSerifTypefaceButton = segmentButtonProvider(text: "PT Serif", font: R.font.pTSerifRegular(size: 16)!, selected: false)
        let ptSansTypefaceButton = segmentButtonProvider(text: "PT Sans", font: R.font.pTSansRegular(size: 16)!, selected: false)
        
        typefaceView.insertSegment(with: andadaTypefaceButton, at: 0, animated: false)
        typefaceView.insertSegment(with: latoTypefaceButton, at: 1, animated: false)
        typefaceView.insertSegment(with: ptSerifTypefaceButton, at: 2, animated: false)
        typefaceView.insertSegment(with: ptSansTypefaceButton, at: 3, animated: false)
        typefaceView.removeBorders()
        typefaceView.removeDividers()
        
        fontSizeView.tickStyle = .rounded
        fontSizeView.tickCount = 5
        fontSizeView.tickSize = CGSize(width: 8, height: 8)
        
        fontSizeView.thumbStyle = .rounded
        fontSizeView.thumbSize = CGSize(width: 20, height: 20)
        fontSizeView.thumbShadowOffset = CGSize(width: 0, height: 2)
        fontSizeView.thumbShadowRadius = 3
        fontSizeView.thumbColor = .tintColor
        
        fontSizeView.backgroundColor = UIColor.clear
        fontSizeView.tintColor = .baseGray1
        fontSizeView.minimumValue = 0
        
        // Force remove fill color
        for layer in fontSizeView.layer.sublayers! {
            layer.backgroundColor = UIColor.clear.cgColor
        }
        
        fontSizeSmallNode.image = segmentButtonProvider(text: "Aa", font: R.font.latoRegular(size: 16)!, selected: false)
        fontSizeLargeNode.image = segmentButtonProvider(text: "Aa", font: R.font.latoBold(size: 24)!, selected: false)
        
        
        dividerNode1.backgroundColor = .baseGray1
        dividerNode2.backgroundColor = .baseGray1
        
        addSubnode(themeNode)
        addSubnode(typefaceNode)
        addSubnode(fontSizeNode)
        addSubnode(fontSizeSmallNode)
        addSubnode(fontSizeLargeNode)
        addSubnode(dividerNode1)
        addSubnode(dividerNode2)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        themeNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 55)
        typefaceNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 55)
        dividerNode1.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 1)
        dividerNode2.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 1)
        
        fontSizeNode.style.preferredSize = CGSize(width: constrainedSize.max.width-120, height: 55)

        
        let sliderSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [fontSizeSmallNode, fontSizeNode, fontSizeLargeNode])
        
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [themeNode, dividerNode1, typefaceNode, dividerNode2, sliderSpec])
    }
    
    override func layout() {
        super.layout()
        var frame = fontSizeNode.frame
        frame.size = CGSize(width: calculatedSize.width-120, height: 55)
        fontSizeNode.frame = frame
        fontSizeView.layoutTrack()
    }
    
    func segmentButtonProvider(text: String, font: UIFont, size: CGFloat = 16, selected: Bool = false) -> UIImage {
        let fontLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        
        fontLabel.font = font
        fontLabel.text = text
        fontLabel.textAlignment = .center
        
        fontLabel.textColor = selected ? .tintColor : .baseGray2
        
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 45))
        wrapperView.addSubview(fontLabel)
        fontLabel.center = wrapperView.center
        
        // Fix for transparent PNG
        wrapperView.isOpaque = false
        fontLabel.isOpaque = false
        
        return UIImage.imageWithView(wrapperView).withRenderingMode(.alwaysOriginal)
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: UIControlState(), barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: .selected, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor(white: 0.5, alpha: 0.1)), for: .highlighted, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor(white: 0.5, alpha: 0.1)), for: [.highlighted, .selected], barMetrics: .default)
        setDividerImage(UIImage.imageWithColor(UIColor.baseGray1), forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)

    }
    
    func removeDividers(){
        setDividerImage(UIImage.imageWithColor(UIColor.clear), forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
}
