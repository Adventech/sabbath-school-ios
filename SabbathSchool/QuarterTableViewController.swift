//
//  QuarterTableViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

class QuarterTableViewController: StretchyTableViewController {
    
    override func viewDidLoad() {
        let image = UIImage(named: "Illustration2")
        let (background, primary, secondary, _) = image!.colors()
        backgroundColor = background
        primaryColor = primary
        secondaryColor = secondary
        
        super.viewDidLoad()
        self.title = "Sabbath School".uppercaseString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as!
        QuarterTableViewCell
        
//        cell.coverImageView.backgroundColor = UIColor.lightGrayColor()
        cell.titleLabel.text = "Rebelion and Redemption"
        cell.subtitleLabel.text = "by Allen Meyer"
        cell.detailLabel.text = "First quarter 2016"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToLesson", sender: indexPath)
    }

    // MARK: - Status Bar Style

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
