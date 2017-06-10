//
//  TableController.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class TableController: ThemeController {
    var tableNode: ASTableNode { return node as! ASTableNode}
    
    init() {
        super.init(node: ASTableNode())
        
        tableNode.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableNode.allowsSelection = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        correctHairline()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selected = tableNode.indexPathForSelectedRow {
            tableNode.view.deselectRow(at: selected, animated: true)
        }
        
        correctHairline()
        colorize()
    }
    
    func correctHairline(){
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
            if self.tableNode.view.contentOffset.y >= -navigationBarHeight {
                navigationController?.navigationBar.showBottomHairline()
            } else {
                navigationController?.navigationBar.hideBottomHairline()
            }
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension TableController: ASTableDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Implement within actual controller
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.correctHairline()
    }
}
