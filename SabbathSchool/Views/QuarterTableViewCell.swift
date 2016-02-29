//
//  QuarterTableViewCell.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 27/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

class QuarterTableViewCell: UITableViewCell {

    @IBOutlet var coverImageView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
