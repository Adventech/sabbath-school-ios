//
//  Constants.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-29.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

let isPad = UIDevice.current.userInterfaceIdiom == .pad
let isPhone = UIDevice.current.userInterfaceIdiom == .phone

struct Constants {
    struct NotificationKey {
    }
    
    struct DefaultKey {
        static let interfaceLanguage = "io.adventech.interfaceLanguage"
        static let quarterlyLanguage = "io.adventech.interfaceLanguage"
        static let firstRun = "io.adventech.firstRun"
        static var preferredBibleVersion: String {
            return "io.adventech.preferredBibleVersion." + "en"
        }
    }
    
    struct Path {
        static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let tmp = NSTemporaryDirectory()
        static let bundlePath = Bundle.main.bundlePath
        static let bundle = Bundle.main
    }
    
    struct Firebase {
        static let apiPrefix = "/api/v1"
        static let languages = apiPrefix + "/languages"
        static let quarterlies = apiPrefix + "/quarterlies"
        static let quarterlyInfo = apiPrefix + "/quarterly-info"
        static let lessonInfo = apiPrefix + "/lesson-info"
        static let reads = apiPrefix + "/reads"
        
        // User created
        static let highlights = "highlights"
        static let comments = "comments"
        static let suggestions = "suggestions"
    }
}
