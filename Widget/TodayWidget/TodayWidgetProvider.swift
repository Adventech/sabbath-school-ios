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

import FirebaseAuth
import FirebaseDatabase
import WidgetKit
import SwiftUI


struct TodayWidgetProvider: TimelineProvider {
    let database: DatabaseReference = Database.database().reference()
    static let placeholderRead: Read = Read.init(
        id: "id",
        date: "26/06/2021",
        index: "en-2021-03-01-01",
        title: "The New Covenant Life",
        content: "",
        bible: []
    )
    static let placeholderDay: Day = Day.init(title: "-------")
    
    func placeholder(in context: Context) -> TodayWidgetEntry {
        TodayWidgetEntry(date: Date.init(), lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo, day: TodayWidgetProvider.placeholderDay)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayWidgetEntry) -> ()) {
        WidgetInteractor.getLessonInfo { (quarterly: Quarterly?, lessonInfo: LessonInfo?) in
            if let lessonInfo = lessonInfo, let day = WidgetInteractor.getTodayFromLessonInfo(lessonInfo: lessonInfo) {
                completion(TodayWidgetEntry(date: Date.init(), lessonInfo: lessonInfo, day: day))
            } else {
                completion(TodayWidgetEntry(date: Date.init(), lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo, day: TodayWidgetProvider.placeholderDay))
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayWidgetEntry>) -> ()) {
        var todayWidgetEntry: TodayWidgetEntry?
        var entries: [TodayWidgetEntry] = []
        
        WidgetInteractor.getLessonInfo { (quarterly: Quarterly?, lessonInfo: LessonInfo?) in
            if let lessonInfo = lessonInfo, let day = WidgetInteractor.getTodayFromLessonInfo(lessonInfo: lessonInfo) {
                todayWidgetEntry = TodayWidgetEntry(date: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!, lessonInfo: lessonInfo, day: day)
            } else {
                todayWidgetEntry = TodayWidgetEntry(date: Calendar.current.date(byAdding: .minute, value: 1, to: Date())!, lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo, day: TodayWidgetProvider.placeholderDay)
            }
            entries.append(todayWidgetEntry!)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}
