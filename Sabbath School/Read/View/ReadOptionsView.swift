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

protocol ReadOptionsDelegate: class {
    func didSelectTheme(theme: ReaderStyle.Theme)
    func didSelectTypeface(typeface: ReaderStyle.Typeface)
    func didSelectSize(size: ReaderStyle.Size)
}

class ReadOptionsView: ASDisplayNode {
    weak var delegate: ReadOptionsDelegate?

    let themeNode = ASDisplayNode { UISegmentedControl(frame: CGRect.zero) }
    var themeView: UISegmentedControl { return themeNode.view as! UISegmentedControl }

    let typefaceNode = ASDisplayNode { UISegmentedControl(frame: CGRect.zero) }
    var typefaceView: UISegmentedControl { return typefaceNode.view as! UISegmentedControl }

    let fontSizeNode = ASDisplayNode {
        DiscreteSlider(frame: CGRect(x: 0, y: 0, width: 375, height: 55))
    }
    var fontSizeView: DiscreteSlider { return fontSizeNode.view as! DiscreteSlider }
    let fontSizeSmallNode = ASTextNode()
    let fontSizeLargeNode = ASTextNode()

    let dividerNode1 = ASDisplayNode()
    let dividerNode2 = ASDisplayNode()

    override init() {
        super.init()

        configureStyles()
        themeView.addTarget(self, action: #selector(themeValueChanged(_:)), for: UIControl.Event.valueChanged)
        typefaceView.addTarget(self, action: #selector(typefaceValueChanged(_:)), for: UIControl.Event.valueChanged)

        let size = currentSize()
        guard let sizeIndex = size.index else { return }
        fontSizeView.value = CGFloat(sizeIndex)
        fontSizeView.tickStyle = .rounded
        fontSizeView.tickCount = 5
        fontSizeView.tickSize = CGSize(width: 8, height: 8)
        fontSizeView.thumbStyle = .rounded
        fontSizeView.thumbSize = CGSize(width: 20, height: 20)
        fontSizeView.thumbShadowOffset = CGSize(width: 0, height: 2)
        fontSizeView.thumbShadowRadius = 3
        fontSizeView.backgroundColor = UIColor.clear
        fontSizeView.minimumValue = 0

        fontSizeView.addTarget(self, action: #selector(fontsizeValueChanged(_:)), for: UIControl.Event.valueChanged)

        for layer in fontSizeView.layer.sublayers! {
            layer.backgroundColor = UIColor.clear.cgColor
        }
        
        fontSizeSmallNode.attributedText = TextStyles.readOptionsFontSizeSmallest(string: "Aa".localized())
        fontSizeLargeNode.attributedText = TextStyles.readOptionsFontSizeLargest(string: "Aa".localized())

        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        themeNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(55))
        typefaceNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(55))
        dividerNode1.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(1))
        dividerNode2.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(1))
        fontSizeSmallNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(60), height: ASDimensionMake(.auto, 0))
        fontSizeLargeNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(60), height: ASDimensionMake(.auto, 0))
        fontSizeNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width-120), height: ASDimensionMake(55))

        let sliderSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [fontSizeSmallNode, fontSizeNode, fontSizeLargeNode])

        let mainLayout = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [themeNode, dividerNode1, typefaceNode, dividerNode2, sliderSpec])
        
        var topMargin: CGFloat = 0
        if #available(iOS 11.0, *) {
            topMargin = 10
        }
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: topMargin, left: 0, bottom: 0, right: 0), child: mainLayout)
    }

    override func layout() {
        super.layout()
        var frame = fontSizeNode.frame
        frame.size = CGSize(width: calculatedSize.width-120, height: 55)
        fontSizeNode.frame = frame
        fontSizeView.layoutTrack()
    }

    private func setupThemeSegmentControl() {
        themeView.removeAllSegments()
        
        themeView.insertSegment(withTitle: "Light".localized(), at: 0, animated: false)
        themeView.insertSegment(withTitle: "Sepia".localized(), at: 1, animated: false)
        themeView.insertSegment(withTitle: "Dark".localized(), at: 2, animated: false)
        
        themeView.setTitleTextAttributes(TextStyles.readOptionsButtonStyle(), for: .normal)
        themeView.setTitleTextAttributes(TextStyles.readOptionsSelectedButtonStyle(), for: .selected)
        themeView.setTitleTextAttributes(TextStyles.readOptionsSelectedButtonStyle(), for: .highlighted)
        
        switch currentTheme() {
        case .light:
            themeView.selectedSegmentIndex = 0
            break
        case .sepia:
            themeView.selectedSegmentIndex = 1
            break
        case .dark:
            themeView.selectedSegmentIndex = 2
            break
        }
        
        themeView.removeBorders()
    }

    private func setupTypefaceSegmentControl() {
        typefaceView.removeAllSegments()

        typefaceView.insertSegment(withTitle: "Andada".localized(), at: 0, animated: false)
        typefaceView.insertSegment(withTitle: "Lato".localized(), at: 1, animated: false)
        typefaceView.insertSegment(withTitle: "PT Serif".localized(), at: 2, animated: false)
        typefaceView.insertSegment(withTitle: "PT Sans".localized(), at: 3, animated: false)
        
        typefaceView.setTitleTextAttributes(TextStyles.readOptionsButtonStyle(), for: .normal)
        typefaceView.setTitleTextAttributes(TextStyles.readOptionsSelectedButtonStyle(), for: .selected)
        typefaceView.setTitleTextAttributes(TextStyles.readOptionsSelectedButtonStyle(), for: .highlighted)
        
        switch currentTypeface() {
        case .andada:
            typefaceView.selectedSegmentIndex = 0
            break
        case .lato:
            typefaceView.selectedSegmentIndex = 1
            break
        case .ptSerif:
            typefaceView.selectedSegmentIndex = 2
            break
        case .ptSans:
            typefaceView.selectedSegmentIndex = 3
            break
        }

        typefaceView.removeBorders()
        typefaceView.removeDividers()
    }
    
    func configureStyles() {
        backgroundColor = .baseBackground
        dividerNode1.backgroundColor = .shimmerringColor
        dividerNode2.backgroundColor = .shimmerringColor
        fontSizeView.thumbColor = .readOptionsTickColor
        fontSizeView.tintColor = .shimmerringColor
        setupThemeSegmentControl()
        setupTypefaceSegmentControl()
    }

    @objc func themeValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let theme = ReaderStyle.Theme.items[selectedIndex]

        UserDefaults.standard.set(theme.rawValue, forKey: Constants.DefaultKey.readingOptionsTheme)
        delegate?.didSelectTheme(theme: theme)
    }

    @objc func typefaceValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let typeface = ReaderStyle.Typeface.items[selectedIndex]

        UserDefaults.standard.set(typeface.rawValue, forKey: Constants.DefaultKey.readingOptionsTypeface)
        delegate?.didSelectTypeface(typeface: typeface)
    }

    @objc func fontsizeValueChanged(_ sender: DiscreteSlider) {
        let selectedIndex = Int(sender.value)
        let size = ReaderStyle.Size.items[selectedIndex]

        UserDefaults.standard.set(size.rawValue, forKey: Constants.DefaultKey.readingOptionsSize)
        delegate?.didSelectSize(size: size)
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: .selected, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: .highlighted, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: .highlighted, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.clear), for: [.highlighted, .selected], barMetrics: .default)
        setDividerImage(UIImage.imageWithColor(.shimmerringColor), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    func removeDividers() {
        setDividerImage(UIImage.imageWithColor(UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
}
