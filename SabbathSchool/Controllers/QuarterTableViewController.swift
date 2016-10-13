//
//  QuarterTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class QuarterTableViewController: StretchyTableViewController {
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        let image = R.image.illustration2()
        let (background, primary, secondary, _) = image!.colors()
        backgroundColor = background
        primaryColor = primary
        secondaryColor = secondary
        
        super.viewDidLoad()
        self.title = "Sabbath School".uppercased()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.quarterCell, for: indexPath)!
        
//        cell.coverImageView.backgroundColor = UIColor.lightGrayColor()
        cell.titleLabel.text = "Rebelion and Redemption"
        cell.subtitleLabel.text = "by Allen Meyer"
        cell.detailLabel.text = "First quarter 2016"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: R.segue.quarterTableViewController.segueToLesson, sender: indexPath)
    }
    
    // MARK: - NavBar Actions
    
    @IBAction func didTapOnSettings(_ sender: AnyObject) {
        
    }
    
    @IBAction func didTapOnFilter(_ sender: AnyObject) {
        
    }
    

    // MARK: - Status Bar Style

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
