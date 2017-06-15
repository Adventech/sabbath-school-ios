//
//  SettingsView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-14.
//  Copyright © 2017 Adventech. All rights reserved.
//

import AsyncDisplayKit

class SettingsView: ASTableNode {
    override public init(style: UITableViewStyle){
        super.init(style: style)
        self.view.separatorColor = .baseGray7
        self.view.backgroundColor = .baseGray6
        self.view.separatorInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)        
    }
}
