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

struct WidgetInteractor {
    enum IndexType: String {
        case read
        case lessonInfo
    }
    static let database: DatabaseReference = Database.database().reference()
    
    static func getLessonInfo(completion: @escaping (Quarterly?, LessonInfo?) -> Void) {
        getCurrentIndex (indexType: .lessonInfo) { (quarterly: Quarterly?, lessonIndex: String?) in
            if let lessonIndex = lessonIndex, let quarterly = quarterly {
                database.child(Constants.Firebase.lessonInfo).child(lessonIndex).observe(.value, with: { (snapshot) in
                    guard let json = snapshot.data else { return }
                    do {
                        let item: LessonInfo = try FirebaseDecoder().decode(LessonInfo.self, from: json)
                        completion(quarterly, item)
                    } catch {
                        completion(nil, nil)
                    }
                }) { (error) in
                    completion(nil, nil)
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    static func getTodayFromLessonInfo(lessonInfo: LessonInfo) -> Day? {
        let today = Date()
        
        if let day = lessonInfo.days.first(where: { (Calendar.current.compare(today, to: $0.date, toGranularity: .day) == .orderedSame) }) {
            return day
        }
        
        return lessonInfo.days.first
    }
    
    static func getToday(completion: @escaping (Read?) -> Void) {
        getCurrentIndex(indexType: .lessonInfo) { (quarterly: Quarterly?, readIndex: String?) in
            if let readIndex = readIndex {
                getRead(readIndex: readIndex) { (read: Read?) in
                    if let read = read {
                        completion(read)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    static func getCurrentIndex(indexType: IndexType, completion: @escaping (Quarterly?, String?) -> Void) {
        if Auth.auth().currentUser == nil {
           completion(nil, nil)
        }
        
        let language = PreferencesShared.currentLanguage()
        
        database.child(Constants.Firebase.quarterlies).child(language.code).observe(.value, with: { (snapshot) in
            guard let json = snapshot.data else { return }

            do {
                let quarterlies: [Quarterly] = try FirebaseDecoder().decode([Quarterly].self, from: json)
                
                let today = Date()
                var found = false
                
                for quarterly in quarterlies {
                    let start = Calendar.current.compare(quarterly.startDate, to: today, toGranularity: .day)
                    let end = Calendar.current.compare(quarterly.endDate, to: today, toGranularity: .day)
                    let fallsBetween = ((start == .orderedAscending) || (start == .orderedSame)) && ((end == .orderedDescending) || (end == .orderedSame))

                    if fallsBetween && !found {
                        var day = 1
                        var week = 1
                        
                        var target = quarterly.startDate
                        while (Calendar.current.compare(today, to: target, toGranularity: .day) != .orderedSame) {
                            day += 1
                            if (day == 8) {
                                day = 1
                                week += 1
                            }
                            target = Calendar.current.date(byAdding: .day, value: 1, to: target)!
                        }
                        
                        found = true
                        
                        if indexType == IndexType.lessonInfo {
                            completion(quarterly, String.init(format: "%@-%02d", quarterly.index, week))
                        } else {
                            completion(quarterly, String.init(format: "%@-%02d-%02d", quarterly.index, week, day))
                        }
                    }
                }
                
                if (!found) {
                    if let quarterly = quarterlies.first {
                        completion(quarterly, String.init(format: "%@-%02d", quarterly.index, 1))
                    }
                    
                }
            } catch {
                completion(nil, nil)
            }
        }) { (error) in
            completion(nil, nil)
        }
        return
    }
    
    static func getRead(readIndex: String, completion: @escaping (Read?) -> Void) {
        database.child(Constants.Firebase.reads).child(readIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.data else { return }
            do {
                let read: Read = try FirebaseDecoder().decode(Read.self, from: json)
                completion(read)
            } catch {
                completion(nil)
            }
        }) { (error) in
            completion(nil)
        }
        return
    }
}
