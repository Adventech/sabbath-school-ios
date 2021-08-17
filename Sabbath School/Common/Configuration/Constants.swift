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

import UIKit

struct Constants {    
    struct DefaultKey {
        static let gcmMessageIDKey = "gcm.message_id"
        static let interfaceLanguage = "io.adventech.interfaceLanguage"
        static let quarterlyLanguage = "io.adventech.interfaceLanguage"
        static let firstRun = "io.adventech.firstRun"
        static let tintColor = "io.adventech.tintColor"
        static let preferredBibleVersion = "io.adventech.preferredBibleVersion."
        static let lastQuarterlyIndex = "io.adventech.lastQuarterlyIndex"
        static let latestReaderBundleTimestamp = "io.adventech.latestReaderBundleTimestamp"

        static let readingOptionsTheme = "io.adventech.readingOptionsTheme"
        static let readingOptionsTypeface = "io.adventech.readingOptionsTypeface"
        static let readingOptionsSize = "io.adventech.readingOptionsSize"
        static let settingsReminderStatus = "io.adventech.settings.reminderStatus"
        static let settingsReminderTime = "io.adventech.settings.reminderTime"
        static let settingsDefaultReminderTime = "08:00"
        static let settingsTheme = "io.adventech.settings.theme"
        
        static let gcPopup = "io.adventech.gcpopup"
        static let appleAuthorizedUserIdKey = "io.adventech.appleAuthorizedUserIdKey"
        static let shortcutItem = "io.adventech.shortcutItem"
        
        static let spotlightDomain = "io.adventech.sabbathSchool"
        
        static let migrationToAppGroups = "io.adventech.migrationToAppGroups"
        static let appGroupName = "group.com.cryart.SabbathSchool"
    }

    struct Path {
        static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let tmp = NSTemporaryDirectory()
        static let bundlePath = Bundle.main.bundlePath
        static let bundle = Bundle.main
        static let readerBundleZip = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!.appendingPathComponent("sabbath-school-reader-latest.zip")
        static let readerBundle = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!.appendingPathComponent("sabbath-school-reader-latest/index.html")
        static let readerBundleDir = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!.appendingPathComponent("sabbath-school-reader-latest")
    }

    struct Firebase {
        static let apiPrefix = "/api/v1"
        static let languages = apiPrefix + "/languages"
        static let quarterlies = apiPrefix + "/quarterlies"
        static let quarterlyInfo = apiPrefix + "/quarterly-info"
        static let lessonInfo = apiPrefix + "/lesson-info"
        static let reads = apiPrefix + "/reads"
        static let audio = apiPrefix + "/audio"

        #if DEBUG
        struct Storage {
            struct ReaderPath {
                static let prod = "gs://sabbath-school-stage.appspot.com/sabbath-school-reader-latest.zip"
                static let stage =  "gs://sabbath-school-stage.appspot.com/sabbath-school-reader-latest.zip"
            }
        }
        #else
        struct Storage {
            struct ReaderPath {
                static let prod = "gs://blistering-inferno-8720.appspot.com/sabbath-school-reader-latest.zip"
                static let stage =  "gs://blistering-inferno-8720.appspot.com/sabbath-school-reader-latest.zip"
            }
        }
        #endif

        // User created
        static let highlights = "highlights"
        static let comments = "comments"
        static let suggestions = "suggestions"
    }
    
    struct URLs {
        #if DEBUG
        static let web = "https://sabbath-school-stage.adventech.io/"
        #else
        static let web = "https://sabbath-school.adventech.io/"
        #endif
        static let webReplacementRegex = "api/v1/|quarterlies/|lessons/|days/|read/"
        
        static let webLinkRegex = #"(^\/[a-z]{2,}\/?$)|(^\/[a-z]{2,}\/\d{4}-\d{2}(-[a-z]{2})?\/?$)|(^\/[a-z]{2,}\/\d{4}-\d{2}(-[a-z]{2})?\/\d{2}\/?$)|(^\/[a-z]{2,}\/\d{4}-\d{2}(-[a-z]{2})?\/\d{2}\/\d{2}(-.+)?\/?$)"#
    }
    
    struct NotificationKey {}
    
    struct Widgets {
        static let todayWidget = "io.adventech.SabbathSchool.TodayWidget"
        static let featuredTodayWidget = "io.adventech.SabbathSchool.FeaturedTodayWidget"
        static let lessonInfoWidget = "io.adventech.SabbathSchool.LessonInfoWidget"
    }
}
