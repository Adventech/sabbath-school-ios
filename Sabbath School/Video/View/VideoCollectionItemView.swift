/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

enum VideoCollectionItemViewMode {
    case horizontal
    case vertical
}

class VideoCollectionItemView: ASCellNode {
    var cover: RoundedCornersImage!
    let title = ASTextNode()
    let subtitle = ASTextNode()
    let duration = MediaButtonNode()
    let durationEnabled: Bool
    let viewMode: VideoCollectionItemViewMode
    let featured: Bool
    
    init(video: Video, viewMode: VideoCollectionItemViewMode = .vertical, featured: Bool = false) {
        self.durationEnabled = video.duration != nil
        self.viewMode = viewMode
        self.featured = featured
        super.init()
        
        cover = RoundedCornersImage(
            imageURL: video.thumbnail,
            corner: 6.0,
            size: nil,
            backgroundColor: AppStyle.Base.Color.background
        )
        
        cover.shadowColor = UIColor.baseGray3.cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 6
        cover.shadowOpacity = 0.3
        cover.clipsToBounds = false
        cover.style.alignSelf = .stretch
        
        title.attributedText = AppStyle.Video.Text.title(string: video.title, featured: featured)
        title.maximumNumberOfLines = 1
        title.truncationMode = .byTruncatingTail
        
        subtitle.attributedText = AppStyle.Video.Text.subtitle(string: video.artist)
        subtitle.maximumNumberOfLines = 1
        subtitle.truncationMode = .byTruncatingTail
        
        duration.setAttributedTitle(AppStyle.Video.Text.duration(string: video.duration ?? ""), for: .normal)
        duration.cornerRadius = 3
        duration.backgroundColor = .baseGray4
        
        backgroundColor = AppStyle.Base.Color.background
        
        selectionStyle = .none
        
        automaticallyManagesSubnodes = true
        
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let yInset: CGFloat = viewMode == .horizontal ? 0 : 10
        let xInset: CGFloat = viewMode == .horizontal ? 10 : 20
        
        let size = featured
            ? CGSize(
                width: constrainedSize.max.width-xInset*2,
                height: (constrainedSize.max.width-xInset*2) / (AppStyle.Video.Size.thumbnail().width / AppStyle.Video.Size.thumbnail().height)
            )
            : AppStyle.Video.Size.thumbnail(viewMode: viewMode, constrainedWidth: constrainedSize.max.width)
        
        cover.style.preferredSize = size
        cover.imageNode.style.preferredSize = size
        
        let titleSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: [title, subtitle])
        
        if !featured {
            cover.style.spacingBefore = viewMode == .horizontal ? 10 : 0
            cover.style.spacingAfter = viewMode == .horizontal ? 10 : 0
            titleSpec.style.flexGrow = 1.0
            titleSpec.style.flexShrink = 1.0
            titleSpec.style.maxWidth = ASDimension(unit: .points, value: size.width)
        }
        
        duration.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        let durationSpec = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: CGFloat.infinity, left: CGFloat.infinity, bottom: 10, right: 10),
            child: duration)
        
        let coverSpec = ASOverlayLayoutSpec(
            child: cover,
            overlay: durationSpec)
        
        var mainSpecChildren: [ASLayoutElement] = [titleSpec]
        
        mainSpecChildren.insert(durationEnabled ? coverSpec : cover, at: 0)
        
        let mainSpec = ASStackLayoutSpec(
            direction: featured ? .vertical : viewMode == .horizontal ? .vertical : .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: featured ? .start : viewMode == .horizontal ? .start : .center,
            children: mainSpecChildren)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: featured ? yInset + 10 : yInset, left: xInset, bottom: featured ? yInset * 2 : yInset, right: xInset), child: mainSpec)
    }
}
