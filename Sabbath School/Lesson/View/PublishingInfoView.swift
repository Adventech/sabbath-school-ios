//
//  PublishingInfoView.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 17/04/22.
//  Copyright © 2022 Adventech. All rights reserved.
//

import AsyncDisplayKit

final class PublishingInfoView: ASCellNode {
    private let title = ASTextNode()
    private let seeAllIcon = ASImageNode()

    init(publishingInfo: PublishingInfo, hexArrowColor: String?) {
        super.init()
        self.selectionStyle = .none
        backgroundColor = AppStyle.Base.Color.background
        title.attributedText = AppStyle.Lesson.Text.publishingHouseInfo(string: publishingInfo.message)
        
        seeAllIcon.image = R.image.arrowFilled()
        seeAllIcon.backgroundColor = UIColor(hex: hexArrowColor ?? "")
        seeAllIcon.cornerRadius = 15

        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        title.style.flexShrink = 1
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .center,
            children: [title, seeAllIcon]
        )

        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
}

