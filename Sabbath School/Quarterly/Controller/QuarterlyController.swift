//
//  QuarterlyController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit
import FirebaseAuth
import UIKit

final class QuarterlyController: TableController {
    var presenter: QuarterlyPresenterProtocol?
    let animator = PopupTransitionAnimator()
    
    var dataSource = [Quarterly]()
    
    override init() {
        super.init()
        
        tableNode.dataSource = self
        tableNode.allowsSelection = false
        
        title = "Sabbath School".uppercased()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lastQuarterlyIndex = currentQuarterly()
        if !lastQuarterlyIndex.isEmpty {
            presenter?.presentLessonScreen(quarterlyIndex: lastQuarterlyIndex)
        }
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutAction))
        
        let rightButton = UIBarButtonItem(image: R.image.iconNavbarLanguage(), style: .done, target: self, action: #selector(rightAction(sender:)))
        
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = rightButton
        presenter?.configure()
        retrieveQuarterlies()
    }
    
    func retrieveQuarterlies() {
        self.dataSource = [Quarterly]()
        self.tableNode.allowsSelection = false
        self.tableNode.reloadData()
        presenter?.presentQuarterlies()
    }
    
    func rightAction(sender: UIBarButtonItem) {
        let buttonView = sender.value(forKey: "view") as! UIView
        let size = CGSize(width: node.frame.width, height: round(node.frame.height*0.8))
        
        animator.style = .arrow
        animator.fromView = buttonView
        animator.arrowColor = .tintColor
        
        presenter?.presentLanguageScreen(size: size, transitioningDelegate: animator)
    }
    
    func openButtonAction(sender: OpenButton){
        presenter?.presentLessonScreen(quarterlyIndex: dataSource[0].index)
    }
    
    func logoutAction() {
        try! Auth.auth().signOut()
        presenter?.wireFrame?.presentLoginScreen()
    }
}

extension QuarterlyController: QuarterlyControllerProtocol {
    func showQuarterlies(quarterlies: [Quarterly]) {
        self.dataSource = quarterlies
        
        if let colorHex = self.dataSource.first?.colorPrimary {
            self.colorPrimary = UIColor.init(hex: colorHex)
        }
        
        self.colorize()
        self.tableNode.allowsSelection = true
        self.tableNode.reloadData()
        self.correctHairline()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.dataSource.isEmpty {
            let quarterly = dataSource[indexPath.row]
        
            if let colorHex = quarterly.colorPrimary {
                setTranslucentNavigation(true, color: UIColor.init(hex: colorHex), tintColor: .white, titleColor: .white)
            }
        
            presenter?.presentLessonScreen(quarterlyIndex: quarterly.index)
        }
    }
}

extension QuarterlyController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            if self.dataSource.isEmpty {
                return QuarterlyEmptyCell()
            }
            
            let quarterly = self.dataSource[indexPath.row]
            
            if indexPath.row == 0 {
                let node = QuarterlyFeaturedCellNode(quarterly: quarterly)
                node.openButton.addTarget(self, action: #selector(self.openButtonAction(sender:)), forControlEvents: .touchUpInside)
                return node
            }
            
            return QuarterlyCellNode(quarterly: quarterly)
        }
        
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty {
            return 6
        }
        return dataSource.count
    }
}
