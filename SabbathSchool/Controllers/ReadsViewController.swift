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
    var collectionNode: ASCollectionNode { return node as! ASCollectionNode}
    let collectionViewLayout = UICollectionViewFlowLayout()
    var database: FIRDatabaseReference!
    var lessonInfo: LessonInfo?
    var reads = [Read]()
    
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
            let node = DayCellNode(read: read)
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
