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
import UIKit

protocol ReadOptionsDelegate {
    func didSelectTheme(theme: String)
    func didSelectTypeface(typeface: String)
    func didSelectSize(size: String)
}

struct ReaderOptionsMapper {
    struct Theme {
        static var Mapper: [Int: String] {
            return [
                0: ReaderStyle.Theme.Light,
                1: ReaderStyle.Theme.Sepia,
                2: ReaderStyle.Theme.Dark
            ]
        }
    }
    
    struct Typeface {
        static var Mapper: [Int: String]{
            return [
                0: ReaderStyle.Typeface.Andada,
                1: ReaderStyle.Typeface.Lato,
                2: ReaderStyle.Typeface.PTSerif,
                3: ReaderStyle.Typeface.PTSans
            ]
        }
    }
    
    struct Size {
        static var Mapper: [Int: String]{
            return [
                0: ReaderStyle.Size.Tiny,
                1: ReaderStyle.Size.Small,
                2: ReaderStyle.Size.Medium,
                3: ReaderStyle.Size.Large,
                4: ReaderStyle.Size.Huge
            ]
        }
        
        static var MapperReverse: [String: Int]{
            return [
                ReaderStyle.Size.Tiny: 0,
                ReaderStyle.Size.Small: 1,
                ReaderStyle.Size.Medium: 2,
                ReaderStyle.Size.Large: 3,
                ReaderStyle.Size.Huge: 4
            ]
        }
    }
}


class ReadOptionsView: ASDisplayNode {
    var delegate: ReadOptionsDelegate?
    
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
        
        setupThemeSegmentControl()
        themeView.addTarget(self, action: #selector(themeValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        setupTypefaceSegmentControl()
        typefaceView.addTarget(self, action: #selector(typefaceValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        var size = currentSize()
        if !size.isEmpty {
            
        } else {
            size = ReaderStyle.Size.Medium
        }
        
        fontSizeView.value = CGFloat(ReaderOptionsMapper.Size.MapperReverse[size]!)
        
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
        
        fontSizeView.addTarget(self, action: #selector(fontsizeValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        for layer in fontSizeView.layer.sublayers! {
            layer.backgroundColor = UIColor.clear.cgColor
        }
        
        fontSizeSmallNode.image = segmentButtonProvider(text: "Aa".localized(), font: R.font.latoRegular(size: 16)!, selected: false)
        fontSizeLargeNode.image = segmentButtonProvider(text: "Aa".localized(), font: R.font.latoBold(size: 24)!, selected: false)
        
        
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
    
    private func setupThemeSegmentControl() {
        let theme = currentTheme()
        
        let lightThemeButton = segmentButtonProvider(text: "Light".localized(), font: R.font.latoRegular(size: 16)!, selected: theme == ReaderStyle.Theme.Light || (theme != ReaderStyle.Theme.Sepia && theme != ReaderStyle.Theme.Dark))
        let sepiaThemeButton = segmentButtonProvider(text: "Sepia".localized(), font: R.font.latoRegular(size: 16)!, selected: theme == ReaderStyle.Theme.Sepia)
        let darkThemeButton = segmentButtonProvider(text: "Dark".localized(), font: R.font.latoRegular(size: 16)!, selected: theme == ReaderStyle.Theme.Dark)
        
        themeView.removeAllSegments()
        themeView.insertSegment(with: lightThemeButton, at: 0, animated: false)
        themeView.insertSegment(with: sepiaThemeButton, at: 1, animated: false)
        themeView.insertSegment(with: darkThemeButton, at: 2, animated: false)
        themeView.removeBorders()
    }
    
    private func setupTypefaceSegmentControl(){
        let typeface = currentTypeface()
        
        let andadaTypefaceButton = segmentButtonProvider(text: "Andada".localized(), font: R.font.loraRegular(size: 16)!, selected:
            (typeface == ReaderStyle.Typeface.Andada) ||
            (typeface != ReaderStyle.Typeface.Lato &&
             typeface != ReaderStyle.Typeface.PTSerif &&
             typeface != ReaderStyle.Typeface.PTSans)
        )
        
        let latoTypefaceButton = segmentButtonProvider(text: "Lato".localized(), font: R.font.latoRegular(size: 16)!, selected: typeface == ReaderStyle.Typeface.Lato)
        let ptSerifTypefaceButton = segmentButtonProvider(text: "PT Serif".localized(), font: R.font.pTSerifRegular(size: 16)!, selected: typeface == ReaderStyle.Typeface.PTSerif)
        let ptSansTypefaceButton = segmentButtonProvider(text: "PT Sans".localized(), font: R.font.pTSansRegular(size: 16)!, selected: typeface == ReaderStyle.Typeface.PTSans)
        
        typefaceView.removeAllSegments()
        typefaceView.insertSegment(with: andadaTypefaceButton, at: 0, animated: false)
        typefaceView.insertSegment(with: latoTypefaceButton, at: 1, animated: false)
        typefaceView.insertSegment(with: ptSerifTypefaceButton, at: 2, animated: false)
        typefaceView.insertSegment(with: ptSansTypefaceButton, at: 3, animated: false)
        
        typefaceView.removeBorders()
        typefaceView.removeDividers()
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
        
        wrapperView.isOpaque = false
        fontLabel.isOpaque = false
        
        return UIImage.imageWithView(wrapperView).withRenderingMode(.alwaysOriginal)
    }
    
    func themeValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let theme = ReaderOptionsMapper.Theme.Mapper[selectedIndex]
        
        UserDefaults.standard.set(theme, forKey: Constants.DefaultKey.readingOptionsTheme)
        setupThemeSegmentControl()
        delegate?.didSelectTheme(theme: theme!)
    }
    
    func typefaceValueChanged(_ sender: UISegmentedControl){
        let selectedIndex = sender.selectedSegmentIndex
        let typeface = ReaderOptionsMapper.Typeface.Mapper[selectedIndex]
        
        UserDefaults.standard.set(typeface, forKey: Constants.DefaultKey.readingOptionsTypeface)
        setupTypefaceSegmentControl()
        delegate?.didSelectTypeface(typeface: typeface!)
    }
    
    func fontsizeValueChanged(_ sender: DiscreteSlider){
        let selectedIndex = Int(sender.value)
        let size = ReaderOptionsMapper.Size.Mapper[selectedIndex]
        
        UserDefaults.standard.set(size, forKey: Constants.DefaultKey.readingOptionsSize)
        
        delegate?.didSelectSize(size: size!)
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: .selected, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor(white: 0.5, alpha: 0.1)), for: .highlighted, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor(white: 0.5, alpha: 0.1)), for: [.highlighted, .selected], barMetrics: .default)
        setDividerImage(UIImage.imageWithColor(UIColor.baseGray1), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    func removeDividers(){
        setDividerImage(UIImage.imageWithColor(UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
}
