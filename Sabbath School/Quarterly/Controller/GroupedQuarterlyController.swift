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

class GroupedQuarterlyController: ASDKViewController<ASDisplayNode> {
    var quarterlyGroupView: QuarterlyGroupView
    let quarterlies: [Quarterly]
    let presenter: QuarterlyPresenterProtocol?
    let quarterlyGroup: QuarterlyGroup
    
    init(presenter: QuarterlyPresenterProtocol?, quarterlyGroup: QuarterlyGroup, quarterlies: [Quarterly], isLast: Bool) {
        self.presenter = presenter
        self.quarterlies = quarterlies
        self.quarterlyGroup = quarterlyGroup
        self.quarterlyGroupView = QuarterlyGroupView(quarterlyGroup: quarterlyGroup, skipGradient: isLast)
        super.init(node: quarterlyGroupView)
        quarterlyGroupView.collectionNode.dataSource = self
        quarterlyGroupView.collectionNode.delegate = self
        quarterlyGroupView.collectionNode.backgroundColor = UIColor.clear.withAlphaComponent(0)
        quarterlyGroupView.seeAll.addTarget(self, action: #selector(self.showSingleGroupQuarterlyScreen(sender:)), forControlEvents: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quarterlyGroupView.collectionNode.view.showsHorizontalScrollIndicator = false
        quarterlyGroupView.collectionNode.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 13, *) {} else {
            if self.traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: quarterlyGroupView.collectionNode.view)
            }
        }
    }
    
    func getLessonControllerForPeek(indexPath: IndexPath, point: CGPoint) -> LessonController? {
        let quarterlyIndex = quarterlies[indexPath.row].index
        let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: false)
        lessonController.isPeeking = true
        lessonController.delegate = self
        return lessonController
    }
    
    @objc func showSingleGroupQuarterlyScreen(sender: ASTextNode) {
        self.presenter?.presentSingleGroupScreen(selectedQuarterlyGroup: quarterlyGroup)
    }
}

extension GroupedQuarterlyController: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !self.quarterlies.isEmpty {
            let quarterly = quarterlies[indexPath.row]
            presenter?.presentLessonScreen(quarterlyIndex: quarterly.index, initiateOpenToday: false)
        }
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            guard let lessonController = self.getLessonControllerForPeek(indexPath: indexPath, point: point) else { return nil }
            return lessonController
        }, actionProvider: { suggestedActions in
            let imageView: UIImage
            imageView = (self.quarterlyGroupView.collectionNode.nodeForItem(at: indexPath) as! QuarterlyItemView).coverImage.imageNode.image!
            let quarterly: Quarterly = self.quarterlies[indexPath.row]
            let share = UIAction(title: "Share".localized(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                let objectToShare = ShareItem(title: quarterly.title, subtitle: quarterly.humanDate, url: quarterly.webURL, image: imageView)
                Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [objectToShare])
            }
            return UIMenu(title: "", children: [share])
        })
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let lessonController = animator.previewViewController as? LessonController else { return }
            self.presenter?.showLessonScreen(lessonScreen: lessonController)
        }
    }
}

extension GroupedQuarterlyController: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
      let cellNodeBlock = { () -> ASCellNode in
        return QuarterlyItemView(quarterly: self.quarterlies[indexPath.row])
      }
        
      return cellNodeBlock
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quarterlies.count
    }
}

extension GroupedQuarterlyController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = quarterlyGroupView.collectionNode.indexPathForItem(at: location) else { return nil }
        guard let lessonController = self.getLessonControllerForPeek(indexPath: indexPath, point: location) else { return nil }
        guard let cell = quarterlyGroupView.collectionNode.cellForItem(at: indexPath) else { return nil }
        previewingContext.sourceRect = (quarterlyGroupView.collectionNode.convert(cell.frame, to: quarterlyGroupView.collectionNode))
        
        return lessonController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let lessonController = viewControllerToCommit as? LessonController else { return }
        presenter?.showLessonScreen(lessonScreen: lessonController)
    }
}

extension GroupedQuarterlyController: LessonControllerDelegate {
    func shareQuarterly(quarterly: Quarterly) {
        Helper.shareTextDialogue(vc: self, sourceView: self.view, objectsToShare: [quarterly.title, quarterly.webURL])
    }
}
