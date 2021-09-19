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

import WidgetKit
import SwiftUI

struct LessonInfoWidgetProvider: TimelineProvider {
    static let placeholderQuarterly: Quarterly = Quarterly(title: "-----")
    static let placeholderLessonInfo: LessonInfo = LessonInfo(
        lesson: Lesson(title: "----"),
        days: [
            Day(title: "------"),
            Day(title: "---------"),
            Day(title: "-----"),
            Day(title: "-----------"),
            Day(title: "--------"),
            Day(title: "--------"),
            Day(title: "---")
        ], pdfs: []
    )
    
    func placeholder(in context: Context) -> LessonInfoWidgetEntry {
        LessonInfoWidgetEntry(date: Date.init(), quarterly: LessonInfoWidgetProvider.placeholderQuarterly, lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo)
    }

    func getSnapshot(in context: Context, completion: @escaping (LessonInfoWidgetEntry) -> ()) {
        WidgetInteractor.getLessonInfo { (quarterly: Quarterly?, lessonInfo: LessonInfo?) in
            if let quarterly = quarterly, let lessonInfo = lessonInfo {
                completion(LessonInfoWidgetEntry(date: Date.init(), quarterly: quarterly, lessonInfo: lessonInfo))
            } else {
                completion(LessonInfoWidgetEntry(date: Date.init(), quarterly: LessonInfoWidgetProvider.placeholderQuarterly, lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo))
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LessonInfoWidgetEntry>) -> ()) {
        var entries: [LessonInfoWidgetEntry] = []
        
        WidgetInteractor.getLessonInfo { (quarterly: Quarterly?, lessonInfo: LessonInfo?) in
            let currentDate = Date()
            let midnight = Calendar.current.startOfDay(for: currentDate)
            let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!

            if let lessonInfo = lessonInfo, let quarterly = quarterly {
                entries.append(LessonInfoWidgetEntry(date: currentDate, quarterly: quarterly, lessonInfo: lessonInfo))
                for offset in 0..<24 {
                    let entryDate = Calendar.current.date(byAdding: .hour, value: offset, to: midnight)!
                    entries.append(LessonInfoWidgetEntry(date: entryDate, quarterly: quarterly, lessonInfo: lessonInfo))
                }
            } else {
                entries.append(LessonInfoWidgetEntry(date: currentDate, quarterly: LessonInfoWidgetProvider.placeholderQuarterly, lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo))
            }
            let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
            completion(timeline)
        }
    }
}
