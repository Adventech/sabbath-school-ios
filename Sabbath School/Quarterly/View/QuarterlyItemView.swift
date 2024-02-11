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
import UIKit

class QuarterlyItemView: ASCellNode {
    var quarterly: Quarterly
    let cover = ASNetworkImageNode()
    var coverImage: RoundedCornersImage!
    let title = ASTextNode()
    let downloadButton = ASButtonNode()
    private let coverCornerRadius = CGFloat(6)

    init(quarterly: Quarterly) {
        self.quarterly = quarterly
        super.init()
        
        title.attributedText = AppStyle.Quarterly.Text.titleV2(string: quarterly.title)
        title.maximumNumberOfLines = 2
        
        cover.shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 5
        cover.shadowOpacity = 0.3
        cover.clipsToBounds = false
        cover.cornerRadius = coverCornerRadius
//        backgroundColor = .red
        coverImage = RoundedCornersImage(imageURL: quarterly.cover, corner: coverCornerRadius, size: AppStyle.Quarterly.Size.coverImage(), backgroundColor: UIColor(hex: quarterly.colorPrimaryDark!))
        coverImage.style.alignSelf = .stretch
        coverImage.imageNode.delegate = self
        
//        downloadButton.alpha = 0.16
//        downloadButton.style.preferredSize = CGSize(width: 15.12, height: 30)
//        downloadButton.imageNode.style.preferredSize = CGSize(width: 15.12, height: 30)
//        downloadButton.imageNode.contentMode = .scaleAspectFit
//        downloadButton.contentEdgeInsets = .init(top: 12, left: 0, bottom: 8, right: 0)
//        downloadButton.setImage(R.image.iconDownloadedQuarterly(), for: .normal)
//        downloadButton.backgroundColor = .blue
        
        downloadButton.alpha = 0.16
        downloadButton.style.preferredSize = CGSize(width: 15.12, height: 30)
        downloadButton.imageNode.style.preferredSize = CGSize(width: 15.12, height: 30)
        downloadButton.imageNode.contentMode = .scaleAspectFit
        downloadButton.contentEdgeInsets = .init(top: 12, left: 0, bottom: 8, right: 0)
        let quarterlyStatus = DownloadQuarterlyState.shared.getStateForQuarterly(quarterlyIndex: quarterly.index)
        debugPrint("l22 quarterlyStatus = \(quarterlyStatus)")
        if  quarterlyStatus == .downloaded {
            setQuarterlyDownloadState(state: .downloaded)
        }
        
        setupObservers()
//        DownloadQuarterlyState.shared.setStateForQuarterly(.downloading, quarterlyIndex: quarterly.id)
        
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cover.style.preferredSize = AppStyle.Quarterly.Size.coverImage()
        coverImage.style.preferredSize = AppStyle.Quarterly.Size.coverImage()
//        title.style.spacingBefore = 10
//        title.style.spacingAfter = 20
        title.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(AppStyle.Quarterly.Size.coverImage().width - 20), height: ASDimensionMake(.auto, 0))
//        title.style.preferredLayoutSize = .init(width: , height: ASDimensionMake(.auto, 0))
        
        let coverSpec = ASBackgroundLayoutSpec(child: coverImage, background: cover)
        
        let vSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .start,
            alignItems: .start,
            children: [title, downloadButton]
        )
        
        vSpec.style.spacingBefore = 10
        vSpec.style.spacingAfter = 0
        vSpec.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(AppStyle.Quarterly.Size.coverImage().width), height: ASDimensionMake(.auto, 0))
        
        let mainSpec = ASStackLayoutSpec(
                   direction: .vertical,
                   spacing: 0,
                   justifyContent: .start,
                   alignItems: .start,
                   children: [coverSpec, vSpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: AppStyle.Quarterly.Size.xPadding(), bottom: 0, right: AppStyle.Quarterly.Size.xPadding()), child: mainSpec)
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        cover.layer.shadowPath = UIBezierPath(roundedRect: cover.bounds, cornerRadius: coverCornerRadius).cgPath
    }
}

extension QuarterlyItemView: ASNetworkImageNodeDelegate {
    func imageNodeDidFinishDecoding(_ imageNode: ASNetworkImageNode) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = imageNode.image else { return }
            Spotlight.indexQuarterly(quarterly: self.quarterly, image: image)
        }
    }
}

// MARK: Setup Observers
extension QuarterlyItemView {
    private func setupObservers() {
        let notificationName = Notification.Name(Constants.DownloadQuarterly.quarterlyDownloadStatus(quarterlyIndex: quarterly.index))
        NotificationCenter.default.addObserver(self, selector: #selector(updateQuarterlyDownloadState), name: notificationName, object: nil)
    }

    @objc private func updateQuarterlyDownloadState(notification: Notification) {
        if let userInfo = notification.userInfo,
           let quarterlyDownloadStatus = userInfo[Constants.DownloadQuarterly.downloadedQuarterlyStatus] as? Int,
           let quarterlyDownloadState = ReadButtonState(rawValue: quarterlyDownloadStatus) {
            setQuarterlyDownloadState(state: quarterlyDownloadState)
        }
    }
    
    func setQuarterlyDownloadState(state: ReadButtonState) {
        switch state {
        case .downloaded:
            downloadButton.setImage(R.image.iconDownloadedQuarterly(), for: .normal)
        case .download, .downloading:
            downloadButton.setImage(nil, for: .normal)
        }
    }
}
