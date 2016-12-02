//
//  QuarterliesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import Unbox

final class QuarterliesViewController: BaseTableViewController {
    var database: FIRDatabaseReference!
    var dataSource = [Quarterly]()
    var languageList = [QuarterlyLanguage]()
    let animator = PopupTransitionAnimator()
    
    // MARK: - Init
    
    override init() {
        super.init()
        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Sabbath School".uppercased()
        backgroundColor = UIColor.tintColor
        
        database = FIRDatabase.database().reference()
        database.keepSynced(true)
        
        loadLanguages()
        loadQuarterlies(language: currentLanguage())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(image: R.image.iconNavbarLanguage(), style: .done, target: self, action: #selector(rightAction(sender:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: - Model fetch
    
    func loadLanguages() {
        database.child(Constants.Firebase.languages).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let json = snapshot.value as? [[String: AnyObject]] else { return }
            
            do {
                let items: [QuarterlyLanguage] = try unbox(dictionaries: json)
                self.languageList = items
            } catch let error {
                print(error)
            }
        })
    }
    
    func loadQuarterlies(language: QuarterlyLanguage) {
        database.child(Constants.Firebase.quarterlies).child(language.code).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [[String: AnyObject]] else { return }
            
            do {
                let items: [Quarterly] = try unbox(dictionaries: json)
                self.dataSource = items
                
                if let colorHex = self.dataSource.first?.colorPrimary {
                    let color = UIColor.init(hex: colorHex)
                    self.view.window?.tintColor = color
                    self.backgroundColor = color
                } else {
                    self.view.window?.tintColor = .baseGreen
                    self.backgroundColor = .baseGreen
                }
                
                self.tableNode.view.reloadData()
            } catch let error {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: - NavBar Actions
    
    func rightAction(sender: UIBarButtonItem) {
        let buttonView = sender.value(forKey: "view") as! UIView
        animator.style = .arrow
        animator.fromView = buttonView
        animator.arrowColor = .tintColor
        
        let languages = LanguagesViewController(languages: languageList)
        languages.delegate = self
        
        let navigation = ASNavigationController(rootViewController: languages)
        navigation.transitioningDelegate = animator
        navigation.modalPresentationStyle = .custom
        navigation.preferredContentSize = CGSize(width: node.frame.width, height: 400)
        present(navigation, animated: true, completion: nil)
    }
}

// MARK: - ASTableDataSource

extension QuarterliesViewController: ASTableDataSource {

    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let quarterly = dataSource[indexPath.row]
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.row == 0 {
                let node = FeaturedQuarterlyCellNode(
                    title: quarterly.title,
                    subtitle: quarterly.humanDate,
                    cover: quarterly.cover
                )
                if let color = quarterly.colorPrimary {
                    node.backgroundColor = UIColor.init(hex: color)
                } else {
                    node.backgroundColor = UIColor.baseGreen
                }
                return node
            }
            
            let node = QuarterlyCellNode(
                title: quarterly.title,
                subtitle: quarterly.humanDate,
                detail: quarterly.description,
                cover: quarterly.cover
            )
            return node
        }
        
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

// MARK: - ASTableDelegate

extension QuarterliesViewController: ASTableDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quarterly = dataSource[indexPath.row]
        let lessonList = LessonsViewController(quarterlyIndex: quarterly.index)
        show(lessonList, sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 30 {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
}

// MARK: - LanguagesViewControllerDelegate

extension QuarterliesViewController: LanguagesViewControllerDelegate {
    func languagesDidSelect(language: QuarterlyLanguage) {
        loadQuarterlies(language: language)
    }
}
