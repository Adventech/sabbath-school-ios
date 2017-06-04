//
//  FirebaseDatabaseInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import FirebaseDatabase

class FirebaseDatabaseInteractor {
    var database: DatabaseReference!
    
    func configure(){
        database = Database.database().reference()
        database.keepSynced(true)
    }
}
