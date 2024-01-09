/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

class SettingsInteractor: NSObject, SettingsInteractorInputProtocol {
    weak var presenter: SettingsInteractorOutputProtocol?
    
    func removeAccount() {
        API.auth.request("\(Constants.API.URL)/auth/delete", method: .post)
            .customValidate().response { [weak self] response in
            if let error = response.error {
                self?.presenter?.onError(error)
                return
            }
            
            self?.presenter?.onSuccess()
        }
    }
    
    func removeAllDownloads() {
//        let lessonInfoStorage = APICache.storage?.transformCodable(ofType: LessonInfo.self)
//        let readStorage = APICache.storage?.transformCodable(ofType: Read.self)
//        let highlightStorage = APICache.storage?.transformCodable(ofType: ReadHighlights.self)
//        let commentStorage = APICache.storage?.transformCodable(ofType: ReadComments.self)
//        let publishingInfoStorage = APICache.storage?.transformCodable(ofType: PublishingInfoData.self)
//        
//        try? lessonInfoStorage?.removeAll()
//        try? readStorage?.removeAll()
//        try? highlightStorage?.removeAll()
//        try? commentStorage?.removeAll()
//        try? publishingInfoStorage?.removeAll()
        
        try? APICache.storage?.removeAll()
        
        DownloadQuarterlyState.shared.removeAll()
    }
}
