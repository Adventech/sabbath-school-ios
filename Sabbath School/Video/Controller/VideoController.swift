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
import MediaPlayer
import AVFoundation
import AVKit

class VideoController: VideoPlaybackDelegatable {
    var player: AVPlayer!
    let videoView = VideoView()
    var dataSource: [VideoInfo] = []
    var clips: [Video] = []
    let lessonIndex: String?
    let readController: ReadController?
    let hasHeader: Bool
    
    init(video: [VideoInfo], lessonIndex: String? = nil, readController: ReadController? = nil) {
        if #available(iOS 13, *) {
            self.hasHeader = true
        } else {
            self.hasHeader = false
        }
        self.dataSource = video
        self.lessonIndex = lessonIndex
        self.readController = readController
        if self.dataSource.count == 1 {
            if let lessonIndex = lessonIndex {
                self.clips = self.dataSource[0].clips.sorted(by: { ($0.targetIndex == lessonIndex ? 0 : 1) < ($1.targetIndex == lessonIndex ? 0 : 1) })
            } else {
                self.clips = self.dataSource[0].clips
            }
            
        }
        super.init(node: videoView)
        self.videoView.videoGroups.dataSource = self
        self.videoView.videoGroups.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video".localized()
        setCloseButton()
        
        self.videoView.videoGroups.backgroundColor = AppStyle.Base.Color.background
        self.videoView.videoGroups.view.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VideoPlayback.shared.controller.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VideoPlayback.shared.controller.delegate = readController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
}

extension VideoController: ASTableDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return !hasHeader ? true : indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasHeader && indexPath.section != 1 { return }
        if self.dataSource.count == 1 {
            var artwork: UIImage? = nil
            if let cell = videoView.videoGroups.nodeForRow(at: indexPath) as? VideoCollectionItemView, let image = cell.cover.imageNode.image {
                artwork = image
            }
            print("SSDEBUG", "clicked")
            self.playVideo(video: self.clips[indexPath.row], artwork: artwork)
        }
    }
}

extension VideoController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if hasHeader && indexPath.section == 0 {
            let cellNodeBlock: () -> ASCellNode = {
                return VideoCollectionHeader()
            }
            return cellNodeBlock
        }
        
        if self.dataSource.count == 1 {
            let cellNodeBlock: () -> ASCellNode = {
                return VideoCollectionItemView(video: self.clips[indexPath.row], featured: indexPath.row == 0)
            }
            return cellNodeBlock
        }
        
        let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
            return VideoCollectionController(lessonIndex: self.lessonIndex, videoInfo: self.dataSource[indexPath.row], videoController: self)
        }, didLoad: nil)
        
        node.layoutIfNeeded()
        node.style.minHeight = ASDimensionMake(AppStyle.Video.Size.thumbnail().height + 140)
        node.style.flexGrow = 1.0
        
        return {
            return node
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let videoGroupsCount = self.dataSource.count == 1 ? self.clips.count : self.dataSource.count
        if #available(iOS 13, *) {
            return section == 0 ? 1 : videoGroupsCount
        }
        return videoGroupsCount
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return hasHeader ? 2 : 1
    }
}

class VideoView: ASDisplayNode {
    let videoGroups = ASTableNode()
    override init() {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        videoGroups.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(0))
        videoGroups.style.flexGrow = 1.0
                
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: videoGroups)
    }
}

class VideoCollectionController: ASDKViewController<ASDisplayNode> {
    var videoCollectionView: VideoCollectionView
    var dataSource: VideoInfo
    let lessonIndex: String?
    let videoController: VideoController
    
    init(lessonIndex: String?, videoInfo: VideoInfo, videoController: VideoController) {
        self.videoController = videoController
        self.lessonIndex = lessonIndex
        self.dataSource = videoInfo
        self.videoCollectionView = VideoCollectionView(collectionTitle: videoInfo.artist)
        super.init(node: videoCollectionView)
        videoCollectionView.collectionNode.dataSource = self
        videoCollectionView.collectionNode.delegate = self
        videoCollectionView.collectionNode.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        videoCollectionView.backgroundColor = AppStyle.Base.Color.background
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoCollectionView.collectionNode.view.showsHorizontalScrollIndicator = false
        videoCollectionView.collectionNode.reloadData()
        if let lessonIndex = self.lessonIndex, let index = self.dataSource.clips.firstIndex(where: { $0.targetIndex == lessonIndex }) {
            DispatchQueue.main.async {
                self.videoCollectionView.collectionNode.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: false)
            }
        }
    }
}

extension VideoCollectionController: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        videoController.playVideo(video: self.dataSource.clips[indexPath.row])
    }
}

extension VideoCollectionController: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
      let cellNodeBlock = { () -> ASCellNode in
        return VideoCollectionItemView(video: self.dataSource.clips[indexPath.row], viewMode: .horizontal)
      }
        
      return cellNodeBlock
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.clips.count
    }
}

class VideoCollectionHeader: ASCellNode {
    let topIndicator = ASDisplayNode()
    let title = ASTextNode()
    
    override init() {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        
        topIndicator.cornerRadius = 3
        topIndicator.backgroundColor = AppStyle.Audio.Color.topIndicator
        title.attributedText = AppStyle.Quarterly.Text.mainTitle(string: "Video")

        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        topIndicator.style.preferredSize = CGSize(width: 50, height: 5)
        
        let topSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .center,
            alignItems: .center,
            children: [topIndicator])
        
        topSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        
        title.style.spacingBefore = 20
        
        let mainSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [topSpec, title])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20), child: mainSpec)
    }
}

class VideoCollectionView: ASCellNode {
    var collectionNode: ASCollectionNode
    let collectionTitle = ASTextNode()
    
    init(collectionTitle: String) {
        let collectionViewLayout = HoriontallySnappingCollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        collectionNode = ASCollectionNode(collectionViewLayout: collectionViewLayout)
        collectionNode.view.decelerationRate = .fast
        collectionNode.backgroundColor = AppStyle.Base.Color.background
        
        self.collectionTitle.attributedText = AppStyle.Video.Text.collectionTitle(string: collectionTitle)
        super.init()
        
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.flexGrow = 1.0
        
        let topSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20), child: collectionTitle)
        
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [topSpec, collectionNode])
    }
}

enum VideoCollectionItemViewMode {
    case horizontal
    case vertial
}

class VideoCollectionItemView: ASCellNode {
    var cover: RoundedCornersImage!
    let title = ASTextNode()
    let subtitle = ASTextNode()
    let viewMode: VideoCollectionItemViewMode
    let featured: Bool
    
    init(video: Video, viewMode: VideoCollectionItemViewMode = .vertial, featured: Bool = false) {
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
        title.maximumNumberOfLines = 2
        title.truncationMode = .byTruncatingTail
        
        subtitle.attributedText = AppStyle.Video.Text.subtitle(string: video.artist)
        subtitle.maximumNumberOfLines = 1
        subtitle.truncationMode = .byTruncatingTail
        
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
            : AppStyle.Video.Size.thumbnail(viewMode: viewMode)
        
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
            titleSpec.style.maxWidth = viewMode == .horizontal ? ASDimensionMake(AppStyle.Video.Size.thumbnail().width) : ASDimensionMake(constrainedSize.max.width - AppStyle.Video.Size.thumbnail().width)
            titleSpec.style.flexGrow = 1.0
            titleSpec.style.flexShrink = 1.0
        }
        
        let mainSpec = ASStackLayoutSpec(
            direction: featured ? .vertical : viewMode == .horizontal ? .vertical : .horizontal,
            spacing: 10,
            justifyContent: .start,
            alignItems: featured ? .start : viewMode == .horizontal ? .start : .center,
            children: [cover, titleSpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: featured ? yInset + 10 : yInset, left: xInset, bottom: featured ? yInset * 2 : yInset, right: xInset), child: mainSpec)
    }
}
