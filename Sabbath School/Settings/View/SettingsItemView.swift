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

enum SettingsDetailsStyle {
    case right
    case bottom
}

final class SettingsItemView: ASCellNode {
    let image = ASImageNode()
    let title = ASTextNode()
    let detail = ASTextNode()
    let switchNode = ASDisplayNode { UISwitch() }
    let datePicker = ASDisplayNode { UIDatePicker() }
    var switchView: UISwitch { return switchNode.view as! UISwitch }
    var datePickerView: UIDatePicker { return datePicker.view as! UIDatePicker }
    var contentStyle: SettingsDetailsStyle = .bottom
    
    fileprivate let disclosureIndicator = ASImageNode()
    fileprivate var showDisclosure = false
    fileprivate var showDetail = false
    fileprivate var showSwitch = false
    fileprivate var showDatePicker = false
    fileprivate var switchState = false

    init(title: String, image: UIImage? = nil, detail: String = "", showDisclosure: Bool = false, danger: Bool = false, actionButton: Bool = false, switchState: Bool? = nil, datePicker: Bool = false) {
        super.init()

        self.showDisclosure = showDisclosure
        self.backgroundColor = AppStyle.Base.Color.background
        
        if let switchState = switchState {
            self.showSwitch = true
            self.switchState = switchState
            self.switchNode.backgroundColor = .clear
            self.switchNode.style.preferredSize = CGSize(width: 51, height: 31)
        }
        
        if datePicker {
            self.showDatePicker = true
        }

        self.title.attributedText = AppStyle.Settings.Text.title(string: title, danger: danger)

        self.image.image = image

        if !detail.isEmpty {
            self.showDetail = true
            self.detail.attributedText = AppStyle.Settings.Text.detail(string: detail)
        }

        if showDisclosure {
            self.disclosureIndicator.image = R.image.iconDisclosureIndicator()
        }

        automaticallyManagesSubnodes = true
    }

    override func didLoad() {
        super.didLoad()
        switchView.isOn = switchState
        switchView.onTintColor = AppStyle.Base.Color.tint
    }
    
    override func layout() {
        super.layout()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var rightStackChildren = [ASLayoutElement]()
        var leftStackChildren: [ASLayoutElement] = [title]
        
        self.datePicker.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(Helper.is24hr() ? 70 : 90), ASDimensionMake(31))

        if showDisclosure { rightStackChildren.insert(disclosureIndicator, at: 0) }
        if showSwitch { rightStackChildren.append(switchNode) }
        if showDatePicker { rightStackChildren.append(datePicker) }
        if showDetail && contentStyle == .right { rightStackChildren.insert(detail, at: 0) }
        if showDetail && contentStyle == .bottom { leftStackChildren.append(detail) }

        let rightSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .end,
            alignItems: .end,
            children: rightStackChildren)

        let leftSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 2,
            justifyContent: .start,
            alignItems: .start,
            children: leftStackChildren)
        leftSpec.style.flexShrink = 1

        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1

        let mainChildren: [ASLayoutElement] = image.image == nil ? [leftSpec, spacer, rightSpec] : [image, leftSpec, spacer, rightSpec]
        let mainSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: .center,
            children: mainChildren)
        mainSpec.style.alignSelf = .stretch

        let insets = showSwitch ? UIEdgeInsets(top: 8.25, left: 15, bottom: 8.25, right: 15) : UIEdgeInsets(top: 14, left: 15, bottom: 14, right: 15)

        return ASInsetLayoutSpec(insets: insets, child: mainSpec)
    }
}
