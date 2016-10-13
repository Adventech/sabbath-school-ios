//
//  LessonsTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

final class LessonsTableViewController: StretchyTableViewController {
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        let image = R.image.illustration()
        let (background, primary, secondary, _) = image!.colors()
        backgroundColor = background
        primaryColor = primary
        secondaryColor = secondary
        
        super.viewDidLoad()
        self.title = "Jeremiah".uppercased()
        
        setBackButtom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavigationBar()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.lessonCell, for: indexPath)!
        cell.numberLabel.text = String(indexPath.row+1)
        cell.titleLabel.text = "The Prophetic Calling of Jeremiah"
        cell.subtitleLabel.text = "Sep 26 - Oct 2"

        return cell
    }
}
