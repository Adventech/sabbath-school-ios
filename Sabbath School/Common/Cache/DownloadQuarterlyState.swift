/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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

import Foundation

class DownloadQuarterlyState {
    
    private var quarterlies = [String: Int]()
    static let shared = DownloadQuarterlyState()
    
    init() {
        var quarterlyDownloaded = PreferencesShared.userDefaults.object(forKey: Constants.DownloadQuarterly.quarterlyDownloaded) as? [String: Int] ?? [:]
        
        quarterlyDownloaded.forEach { (key, value) in
            if value == ReadButtonState.downloading.rawValue {
                quarterlyDownloaded[key] = ReadButtonState.downloading.rawValue
            }
        }
        
        quarterlies = quarterlyDownloaded
    }
    
    func getStateForQuarterly(quarterlyIndex: String) -> ReadButtonState {
        let key = Constants.DownloadQuarterly.quarterlyDownloadStatus(quarterlyIndex: quarterlyIndex)
        return ReadButtonState(rawValue: quarterlies[key] ?? 0) ?? .download
    }
    
    func setStateForQuarterly(_ state: ReadButtonState, quarterlyIndex: String) {
        let key = Constants.DownloadQuarterly.quarterlyDownloadStatus(quarterlyIndex: quarterlyIndex)

        quarterlies[key] = state.rawValue
        PreferencesShared.userDefaults.set(quarterlies, forKey: Constants.DownloadQuarterly.quarterlyDownloaded)
    }
    
    func removeAll() {
        quarterlies.forEach { (key, value) in
            let downloadStatus = ReadButtonState.download.rawValue
            NotificationCenter.default.post(name: Notification.Name(key),
                                            object: nil,
                                            userInfo: [Constants.DownloadQuarterly.downloadedQuarterlyIndex: key,
                                                       Constants.DownloadQuarterly.downloadedQuarterlyStatus: downloadStatus])
        }
        
        quarterlies = [String: Int]()
        PreferencesShared.userDefaults.removeObject(forKey: Constants.DownloadQuarterly.quarterlyDownloaded)
        PreferencesShared.userDefaults.synchronize()
    }
}
