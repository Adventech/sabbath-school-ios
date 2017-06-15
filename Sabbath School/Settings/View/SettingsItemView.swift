//
//  SettingsItemView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-14.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

enum SettingsCellNodeStyle {
    case detailOnRight
    case detailOnBottom
}

final class SettingsItemView: ASCellNode {
    let imageNode = ASImageNode()
    let textNode = ASTextNode()
    let detailTextNode = ASTextNode()
    let switchNode = ASDisplayNode { UISwitch() }
    var switchView: UISwitch { return switchNode.view as! UISwitch }
    var contentStyle: SettingsCellNodeStyle = .detailOnBottom
    fileprivate let disclosureIndicator = ASImageNode()
    fileprivate var showDisclosure = false
    fileprivate var showDetailText = false
    fileprivate var showSwitch = false
    fileprivate var switchState = false
    
    init(text: String, icon: UIImage? = nil, detailText: String = "", showDisclosure: Bool = false, destructive: Bool = false, actionButton: Bool = false, switchState: Bool? = nil) {
        super.init()
        
        self.showDisclosure = showDisclosure
        self.backgroundColor = .white
        
        if let switchState = switchState {
            self.showSwitch = true
            self.switchState = switchState
            switchNode.backgroundColor = .clear
            switchNode.style.preferredSize = CGSize(width: 51, height: 31)
        }
        
        textNode.attributedText = TextStyles.settingsCellStyle(string: text)
        
        imageNode.image = icon
        
        if !detailText.isEmpty {
            showDetailText = true
            detailTextNode.attributedText = TextStyles.settingsCellDetailStyle(string: detailText)
        }
        
        if showDisclosure {
            disclosureIndicator.image = R.image.iconCheckmark()
        }
        
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        switchView.isOn = switchState
        switchView.onTintColor = .tintColor
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var rightStackChildren = [ASLayoutElement]()
        var leftStackChildren: [ASLayoutElement] = [textNode]
        
        if showDisclosure { rightStackChildren.insert(disclosureIndicator, at: 0) }
        if showSwitch { rightStackChildren.append(switchNode) }
        if showDetailText && contentStyle == .detailOnRight { rightStackChildren.insert(detailTextNode, at: 0) }
        if showDetailText && contentStyle == .detailOnBottom { leftStackChildren.append(detailTextNode) }
        
        let rightSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .end,
            alignItems: .center,
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
        
        let mainChildren: [ASLayoutElement] = imageNode.image == nil ? [leftSpec, spacer, rightSpec] : [imageNode, leftSpec, spacer, rightSpec]
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
