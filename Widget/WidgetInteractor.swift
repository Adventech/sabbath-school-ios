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

import Cache

struct WidgetInteractor {
    enum IndexType: String {
        case read
        case lessonInfo
    }
    static let lessonInfoStorage: Storage<String, LessonInfo>? = {
        return APICache.storage?.transformCodable(ofType: LessonInfo.self)
    }()
    
    static let quarterlyStorage: Storage<String, [Quarterly]>? = {
        return APICache.storage?.transformCodable(ofType: [Quarterly].self)
    }()
    
    static func getLessonInfo(completion: @escaping (Quarterly?, LessonInfo?) -> Void) {
        getCurrentIndex (indexType: .lessonInfo) { (quarterly: Quarterly?, lessonIndex: String?) in
            if let lessonIndex = lessonIndex, let quarterly = quarterly {
                let parsedIndex =  Helper.parseIndex(index: lessonIndex)
                let url = "\(Constants.API.URL)/\(parsedIndex.lang)/quarterlies/\(parsedIndex.quarter)/lessons/\(parsedIndex.week)/index.json"
                
                if (try? self.lessonInfoStorage?.existsObject(forKey: url)) != nil {
                    if let lessonInfo = try? self.lessonInfoStorage?.entry(forKey: url) {
                        completion(quarterly, lessonInfo.object)
                    }
                }
                
                API.session.request(url).responseDecodable(of: LessonInfo.self, decoder: Helper.SSJSONDecoder()) { response in
                    guard let lessonInfo = response.value else {
                        completion(nil, nil)
                        return
                    }
                    completion(quarterly, lessonInfo)
                    try? self.lessonInfoStorage?.setObject(lessonInfo, forKey: url)
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
    
    static func getCurrentIndexFromQuarterlies(indexType: IndexType, quarterlies: [Quarterly]) -> (quarterly: Quarterly, index: String) {
        var quarterlies = quarterlies
        let today = Date()
        var found = false
        
        let lastQuarterlyIndex = PreferencesShared.currentQuarterly()
        
        if let index = quarterlies.firstIndex(where: { $0.index == lastQuarterlyIndex }) {
            let lastQuarterly = quarterlies[index]
            quarterlies.remove(at: index)
            quarterlies.insert(lastQuarterly, at: 0)
        }
        
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
                    return (quarterly, String.init(format: "%@-%02d", quarterly.index, week))
                } else {
                    return (quarterly, String.init(format: "%@-%02d-%02d", quarterly.index, week, day))
                }
            }
        }
        
        if (!found) {
            if let quarterly = quarterlies.first {
                return (quarterly, String.init(format: "%@-%02d", quarterly.index, 1))
            }
        }
        return (Quarterly(title: ""), "")
    }
    
    static func getCurrentIndex(indexType: IndexType, completion: @escaping (Quarterly?, String?) -> Void) {
        let language = PreferencesShared.currentLanguage()
        
        let url = "\(Constants.API.URL)/\(language.code)/quarterlies/index.json"
        
        if (try? self.quarterlyStorage?.existsObject(forKey: url)) != nil {
            if let quarterlies = try? self.quarterlyStorage?.entry(forKey: url) {
                let ret = self.getCurrentIndexFromQuarterlies(indexType: indexType, quarterlies: quarterlies.object)
                completion(ret.quarterly, ret.index)
            }
        }
        
        API.session.request(url).responseDecodable(of: [Quarterly].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let quarterlies = response.value else {
                completion(nil, nil)
                return
            }
            let ret = self.getCurrentIndexFromQuarterlies(indexType: indexType, quarterlies: quarterlies)
            completion(ret.quarterly, ret.index)
            try? self.quarterlyStorage?.setObject(quarterlies, forKey: url)
        }
        return
    }
}
