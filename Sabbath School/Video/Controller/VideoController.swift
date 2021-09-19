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

class VideoController: VideoPlaybackDelegatable {
    var player: AVPlayer!
    let videoView = VideoView()
    var dataSource: [VideoInfo] = []
    var clips: [Video] = []
    let lessonIndex: String?
    let readController: VideoPlaybackDelegatable?
    let hasHeader: Bool
    
    init(video: [VideoInfo], lessonIndex: String? = nil, readController: VideoPlaybackDelegatable? = nil) {
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
        if let readController = self.readController {
            VideoPlayback.shared.controller.delegate = readController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let oldHeight = self.view.frame.size.height
        let oldWidth = self.view.frame.size.width
        self.view.frame = UIScreen.main.bounds
        self.view.frame.size.height = oldHeight
        self.view.frame.size.width = oldWidth
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
