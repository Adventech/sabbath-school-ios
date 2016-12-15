//
//  ReadsViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 01/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import Unbox

class ReadsViewController: ASViewController<ASDisplayNode> {
    var collectionNode: ASCollectionNode { return node as! ASCollectionNode }
    let collectionViewLayout = UICollectionViewFlowLayout()
    var database: FIRDatabaseReference!
    var lessonInfo: LessonInfo?
    var reads = [Read]()
    let popupAnimator = PopupTransitionAnimator()
    fileprivate var isAnimating = false
    
    // MARK: - Init
    
    init(lessonIndex: String) {
        super.init(node: ASCollectionNode(collectionViewLayout: collectionViewLayout))
        
        collectionNode.delegate = self
        collectionNode.dataSource = self
        
        database = FIRDatabase.database().reference()
        database.keepSynced(true)
        
        loadLessonInfo(lessonIndex: lessonIndex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButtom()
        
        // Fix offset
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
            let height = navigationBarHeight+20
            collectionNode.view.contentOffset = CGPoint(x: 0, y: -height)
            collectionNode.view.contentInset = UIEdgeInsets(top: -height, left: 0, bottom: 0, right: 0)
        }

        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsets.zero
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        
        let collectionView = collectionNode.view
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavigationBar()
    }
    
    // MARK: - Navigation Bar Animation
    
    func showNavigationBar() {
        if (isAnimating) { return }
        
        let navBar = self.navigationController?.navigationBar
        if (navBar?.layer.animation(forKey: kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.2
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.add(animation, forKey: kCATransition)
        }
        setTranslucentNavigation(true, color: .tintColor, tintColor: .white, titleColor: .white)
    }
    
    func hideNavigationBar() {
        if (isAnimating) { return }
        
        let navBar = self.navigationController?.navigationBar
        if (navBar?.layer.animation(forKey: kCATransition) == nil) {
            let animation = CATransition()
            animation.duration = 0.1
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            navBar?.layer.add(animation, forKey: kCATransition)
        }
        self.setTransparentNavigation()
    }
    
    // MARK: Load Data
    
    func loadLessonInfo(lessonIndex: String) {
        database.child(Constants.Firebase.lessonInfo).child(lessonIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
            
            do {
                let item: LessonInfo = try unbox(dictionary: json)
                self.lessonInfo = item
                self.loadReads()
            } catch let error {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadReads() {
        guard let days = lessonInfo?.days else { return }
        
        days.forEach { (day) in
            database.child(Constants.Firebase.reads).child(day.index).observe(.value, with: { (snapshot) in
                guard let json = snapshot.value as? [String: AnyObject] else { return }
                
                do {
                    let item: Read = try unbox(dictionary: json)
                    
                    // TODO: Do not append items directly, first check if they exists.
                    self.reads.append(item)
                    
                    if days.count == self.reads.count {
                        self.collectionNode.view.reloadData()
                    }
                } catch let error {
                    print(error)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - ASCollectionDataSource

extension ReadsViewController: ASCollectionDataSource {
    
    func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let read = reads[indexPath.row]
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            let node = DayCellNode(read: read, cover: self.lessonInfo?.lesson.cover)
            node.delegate = self
            return node
        }
        
        return cellNodeBlock
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let days = lessonInfo?.days else { return 0 }
        return days.count
    }
}

// MARK: - ASCollectionDelegate

extension ReadsViewController: ASCollectionDelegate {
    
    @objc(collectionView:constrainedSizeForNodeAtIndexPath:)
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMakeExactSize(node.calculatedSize)
    }
}

// MARK: - Animation delegate

extension ReadsViewController: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        isAnimating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
}

// MARK: - DayCellNodeDelegate

extension ReadsViewController: DayCellNodeDelegate {
    
    func dayCellNode(dayCellNode: DayCellNode, openVerse: String) {
        let indexPath = collectionNode.view.indexPath(for: dayCellNode)
        let read = reads[indexPath.row]
        
        if read.bible.count > 0 {
            popupAnimator.style = .square
            
            let bibleVerses = BibleVersesViewController(bibleVerses: read.bible, verse: openVerse)
            
            let navigation = ASNavigationController(rootViewController: bibleVerses)
            navigation.transitioningDelegate = popupAnimator
            navigation.modalPresentationStyle = .custom
            navigation.preferredContentSize = CGSize(
                width: round(node.frame.width*0.9),
                height: round(node.frame.height*0.8)
            )
            present(navigation, animated: true, completion: nil)
        } else {
            // TODO: Show error message
            print("No verses available")
        }
        
    }
}
