/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SwiftDate
import UIKit

let isPad = UIDevice.current.userInterfaceIdiom == .pad
let isPhone = UIDevice.current.userInterfaceIdiom == .phone

struct Constants {
    struct NotificationKey {
    }
    
    struct DefaultKey {
        static let gcmMessageIDKey = "gcm.message_id"
        static let interfaceLanguage = "io.adventech.interfaceLanguage"
        static let quarterlyLanguage = "io.adventech.interfaceLanguage"
        static let firstRun = "io.adventech.firstRun"
        static var preferredBibleVersion: String {
            return "io.adventech.preferredBibleVersion." + currentLanguage().code
        }
        static let lastQuarterlyIndex = "io.adventech.lastQuarterlyIndex"
        
        static let readingOptionsTheme = "io.adventech.readingOptionsTheme"
        static let readingOptionsTypeface = "io.adventech.readingOptionsTypeface"
        static let readingOptionsSize = "io.adventech.readingOptionsSize"
        static let settingsReminderStatus = "io.adventech.settings.reminderStatus"
        static let settingsReminderTime = "io.adventech.settings.reminderTime"
        static let settingsDefaultReminderTime = "08:00"
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
