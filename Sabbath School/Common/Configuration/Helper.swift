/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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
import Foundation

struct ParsedIndex {
    var lang = ""
    var quarter = ""
    var week = ""
    var day = ""
}

struct Helper {
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isLandscape: Bool {
        #if os(tvOS)
        return false
        #else
        let orientation = UIDevice.current.orientation
        return orientation == .landscapeLeft || orientation == .landscapeRight
        #endif
    }
    
    static func is24hr() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return dateFormat.firstIndex(of: "a") == nil
    }
    
    static func firstRun() -> Bool {
        return !PreferencesShared.userDefaults.bool(forKey: Constants.DefaultKey.firstRun)
    }
    
    static func isDarkMode() -> Bool {
        guard #available(iOS 13.0, *) else { return false }
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    static func getCurrentLessonIndex(lessons: [Lesson]) -> String {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let hour = Calendar.current.component(.hour, from: today)
        var prevLessonIndex: String? = nil
        
        for lesson in lessons {
            let start = Calendar.current.compare(lesson.startDate, to: today, toGranularity: .day)
            let end = Calendar.current.compare(lesson.endDate, to: today, toGranularity: .day)
            let fallsBetween = ((start == .orderedAscending) || (start == .orderedSame)) && ((end == .orderedDescending) || (end == .orderedSame))

            if fallsBetween {
                if (weekday == 7 && hour < 12 && prevLessonIndex != nil) {
                    return prevLessonIndex!
                } else {
                    return lesson.index
                }
            }
            prevLessonIndex = lesson.index
        }

        if let firstLesson = lessons.first {
            return firstLesson.index
        }
        
        return ""
    }
    
    static func getCurrentQuarterlyIndex(quarterlies: [Quarterly]) -> String {
        let today = Date()
        
        for quarterly in quarterlies {
            let start = Calendar.current.compare(quarterly.startDate, to: today, toGranularity: .day)
            let end = Calendar.current.compare(quarterly.endDate, to: today, toGranularity: .day)
            let fallsBetween = ((start == .orderedAscending) || (start == .orderedSame)) && ((end == .orderedDescending) || (end == .orderedSame))

            if fallsBetween {
                return quarterly.index
            }
        }

        if let firstQuarterly = quarterlies.first {
            return firstQuarterly.index
        }
        
        return ""
    }
    
    static func PDFDownloadFileURL(fileName: String) -> URL {
        let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
        return (docURL?.appendingPathComponent(fileName))!
    }
    
    static func PDFDownloadFileExists(fileName: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)

        let filePath = url.appendingPathComponent(fileName).path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
    }
    
    static func ShareFileURL(fileName: String) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
    
    static func SSJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    static func parseIndex(index: String) -> ParsedIndex {
        var pI = ParsedIndex()
        
        do {
            let regex = try NSRegularExpression(pattern: Constants.URLs.indexPattern, options: [])

            let nsrange = NSRange(index.startIndex..<index.endIndex, in: index)
            if let match = regex.firstMatch(in: index, options: [], range: nsrange) {
                for component in ["lang", "quarter", "week", "day"] {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound, let range = Range(nsrange, in: index) {
                        switch component {
                        case "lang":
                            pI.lang = "\(index[range])"
                            break
                        case "quarter":
                            pI.quarter = "\(index[range])"
                            break
                        case "week":
                            pI.week = "\(index[range])"
                            break
                        case "day":
                            pI.day = "\(index[range])"
                            break
                        default:
                            break
                        }
                    }
                }
            }
        } catch {}
        return pI
    }
}
