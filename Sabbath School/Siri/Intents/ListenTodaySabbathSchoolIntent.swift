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

import AppIntents
import UIKit
import SwiftAudio

@available(iOS 16.0, *)
struct ListenTodaySabbathSchoolIntent: AudioStartingIntent {
    
    static var title: LocalizedStringResource = "Starting Sabbath School"
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let lastQuarterlyIndex = Preferences.currentQuarterly()
        retrieveAudio(quarterlyIndex: lastQuarterlyIndex)
        
        return .result(value: true)
    }
    
    func retrieveAudio(quarterlyIndex: String) {
        let audioInteractor = AudioInteractor()
        let lessonInteractor = LessonInteractor()
        
        lessonInteractor.retrieveQuarterlyInfo(quarterlyIndex: quarterlyIndex) { quarterlyInfo in
            audioInteractor.retrieveAudio(quarterlyIndex: quarterlyIndex) { audio in
                let finalAudio = audio.filter { $0.targetIndex.starts(with: getTodaysLessonIndex(dataSource: quarterlyInfo)) }
                
                let audioItems: [AudioItem] = finalAudio.map { $0.audioItem() }
                
                AudioPlayback.configure()
                try? AudioPlayback.shared.add(items: audioItems, playWhenReady: false)
                try? AudioPlayback.shared.jumpToItem(atIndex: 1, playWhenReady: true)
                
                AudioPlayback.play()
            }
        }
    }
    
    
    func getTodaysLessonIndex(dataSource: QuarterlyInfo?) -> String {
        guard let lessons = dataSource?.lessons else { return "" }
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
}
