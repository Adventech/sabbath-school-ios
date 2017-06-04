//
//  LessonCellNode.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class LessonCellNode: ASCellNode {
    let titleNode = ASTextNode()
    let subtitleNode = ASTextNode()
    let numberNode = ASTextNode()
    
    init(lesson: Lesson, number: String) {
        super.init()
        
        backgroundColor = UIColor.white
        
        titleNode.attributedText = TextStyles.cellTitleStyle(string: lesson.title)
        subtitleNode.attributedText = TextStyles.cellSubtitleStyle(string: "\(lesson.startDate.stringLessonDate()) - \(lesson.endDate.stringLessonDate())")
        numberNode.attributedText = TextStyles.cellLessonNumberStyle(string: number)
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [titleNode, subtitleNode]
        )
        
        vSpec.style.flexShrink = 1.0
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 15,
            justifyContent: .start,
            alignItems: .center,
            children: [numberNode, vSpec]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: hSpec)
    }
}
