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

import UIKit
import AsyncDisplayKit

class LessonQuarterlyFooter: ASCellNode {
    let copyright = ASTextNode()
    var credits: [(ASTextNode, ASTextNode)]
    var features: [(ASNetworkImageNode, ASTextNode, ASTextNode)]
    

    init(credits: [Credits], features: [Feature]) {
        self.credits = []
        self.features = []
        super.init()
        
        for credit in credits {
            let name = ASTextNode()
            let value = ASTextNode()
            name.attributedText = AppStyle.Lesson.Text.creditsName(string: credit.name)
            value.attributedText = AppStyle.Lesson.Text.creditsValue(string: credit.value)
            
            self.credits.append((name, value))
            
            addSubnode(name)
            addSubnode(value)
        }
        
        for feature in features {
            let image = ASNetworkImageNode()
            let title = ASTextNode()
            let description = ASTextNode()
            
            image.url = feature.image
            image.delegate = self
            
            title.attributedText = AppStyle.Lesson.Text.creditsName(string: feature.title)
            description.attributedText = AppStyle.Lesson.Text.creditsValue(string: feature.description)
            
            self.features.append((image, title, description))
            
            addSubnode(image)
            addSubnode(title)
            addSubnode(description)
        }
        
        let year = Calendar.current.component(.year, from: Date())
        
        copyright.attributedText = AppStyle.Lesson.Text.copyright(string: String(format: "© %d " + "General Conference of Seventh-day Adventists".localized() + "®", year))
        backgroundColor = AppStyle.Lesson.Color.backgroundFooter
        
        addSubnode(copyright)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var mainStackChildren: [ASLayoutElement] = []
        
        for feature in features {
            (feature.0).style.preferredSize = AppStyle.Lesson.Size.featureImage()
            let featureImageNameStack = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 10,
                justifyContent: .start,
                alignItems: .center,
                children: [feature.0, feature.1]
            )
            mainStackChildren.append(
                ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 5,
                    justifyContent: .start,
                    alignItems: .start,
                    children: [featureImageNameStack, feature.2]
                )
            )
        }
        
        for credit in credits {
            mainStackChildren.append(
                ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 5,
                    justifyContent: .start,
                    alignItems: .start,
                    children: [credit.0, credit.1]
                )
            )
        }
        
        mainStackChildren.append(copyright)
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 20,
            justifyContent: .start,
            alignItems: .start,
            children: mainStackChildren
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 25, right: 15), child: vSpec)
    }
}

extension LessonQuarterlyFooter: ASNetworkImageNodeDelegate {
    func imageNodeDidFinishDecoding(_ imageNode: ASNetworkImageNode) {
        guard let image = imageNode.image else { return }
        imageNode.url = nil
        imageNode.image = image.fillAlpha(fillColor: AppStyle.Base.Color.text)
    }
}
