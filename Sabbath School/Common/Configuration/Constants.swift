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
        static let quarterlyGroups = "io.adventech.quarterlyGroups."

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
        
        static let pdfConfigurationPageTransition = "io.adventech.settings.pdf.pageTransition"
        static let pdfConfigurationPageMode = "io.adventech.settings.pdf.pageMode"
        static let pdfConfigurationScrollDirection = "io.adventech.settings.pdf.scrollDirection"
        static let pdfConfigurationSpreadFitting = "io.adventech.settings.pdf.spreadFitting"
        
        static let accountObject = "io.adventech.auth.user"
        static let accountFirebaseMigrated = "io.adventech.auth.firebase.migration"
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
    
    struct API {
        #if DEBUG
        static let GOOGLE_CLIENT_ID = "96814818762-k7l0r7no343dms51ss59q6c5dslujcu7.apps.googleusercontent.com"
        static let HOST = "https://sabbath-school-stage.adventech.io"
        static let LEGACY_API_KEY = "AIzaSyAfnNJPLHamTqxqQEfNVtcVM0_sPSL1mso"
        #else
        static let GOOGLE_CLIENT_ID = "443920152945-d0kf5h2dubt0jbcntq8l0qeg6lbpgn60.apps.googleusercontent.com"
        static let HOST = "https://sabbath-school.adventech.io"
        static let LEGACY_API_KEY = "AIzaSyBcGMSMYFVkKgTuuvUdLgjmEy4CWjmmLNU"
        #endif
        static let URL = "\(Constants.API.HOST)/api/v2"
        static let READER_BUNDLE_FILENAME = "sabbath-school-reader-latest.zip"
    }
    
    struct URLs {
        #if DEBUG
        static let web = "https://sabbath-school-stage.adventech.io/"
        #else
        static let web = "https://sabbath-school.adventech.io/"
        #endif
        static let webReplacementRegex = "api/v1|api/v2/|quarterlies/|lessons/|days/|read/"
        
        static let indexPattern = #"""
(?xi)
(?<lang>
  [a-z]{2,3}
)
-
(?<quarter>
  \d{4}-\d{2}(-[a-z]{2,})?
)
-?
(?<week>
  \d{2}|[a-z-]{1,}
)?
-?
(?<day>
  \d{2}|[a-z-]{1,}
)?
"""#
        
        static let webLinkRegex = #"(^\/[a-z]{2,}\/?$)|(^\/[a-z]{2,}\/\d{4}-\d{2}(-[a-z]{2})?\/?$)|(^\/[a-z]{2,}\/\d{4}-\d{2}(-[a-z]{2})?\/\d{2}\/?$)|(^\/[a-z]{2,}\/\d{4}-\d{2}(-[a-z]{2})?\/\d{2}\/\d{2}(-.+)?\/?$)"#
    }
    
    struct NotificationKey {}
    
    struct Widgets {
        static let todayWidget = "io.adventech.SabbathSchool.TodayWidget"
        static let featuredTodayWidget = "io.adventech.SabbathSchool.FeaturedTodayWidget"
        static let lessonInfoWidget = "io.adventech.SabbathSchool.LessonInfoWidget"
    }
    
    struct WKUserScripts {
        static let disableWKWebViewZoom = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(meta);
            """
    }
}
