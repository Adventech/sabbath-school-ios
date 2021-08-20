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
        var artwork: UIImage? = nil
        if let cell = videoCollectionView.collectionNode.nodeForItem(at: indexPath) as? VideoCollectionItemView, let image = cell.cover.imageNode.image {
            artwork = image
        }
        videoController.playVideo(video: self.dataSource.clips[indexPath.row], artwork: artwork)
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
