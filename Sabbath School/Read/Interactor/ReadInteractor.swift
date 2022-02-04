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

import Alamofire
import FontBlaster
import Zip
import Cache

class ReadInteractor: ReadInteractorInputProtocol {
    private var lessonInfoStorage: Cache.Storage<String, LessonInfo>?
    private var readStorage: Cache.Storage<String, Read>?
    private var highlightStorage: Cache.Storage<String, ReadHighlights>?
    private var commentStorage: Cache.Storage<String, ReadComments>?
    
    weak var presenter: ReadInteractorOutputProtocol?
    var ticker: Int = -1
    
    let dispatchQueue = DispatchQueue(label: "readRetrieve", qos: .background)
    let semaphore = DispatchSemaphore(value: 0)
    
    init () {}
    
    func configure() {
        checkifReaderBundleNeeded()
        self.readStorage = APICache.storage?.transformCodable(ofType: Read.self)
        self.highlightStorage = APICache.storage?.transformCodable(ofType: ReadHighlights.self)
        self.commentStorage = APICache.storage?.transformCodable(ofType: ReadComments.self)
    }

    func retrieveLessonInfo(lessonIndex: String) {
        self.retrieveAudio(quarterlyIndex: String(lessonIndex.prefix(lessonIndex.count-3)))
        self.retrieveVideo(quarterlyIndex: String(lessonIndex.prefix(lessonIndex.count-3)))
        
        let parsedIndex =  Helper.parseIndex(index: lessonIndex)
        
        let url = "\(Constants.API.URL)/\(parsedIndex.lang)/quarterlies/\(parsedIndex.quarter)/lessons/\(parsedIndex.week)/index.json"
        
        var hasCache = false
        
        if (try? self.lessonInfoStorage?.existsObject(forKey: url)) != nil {
            if let lessonInfo = try? self.lessonInfoStorage?.entry(forKey: url) {
                self.presenter?.didRetrieveLessonInfo(lessonInfo: lessonInfo.object)
                self.retrieveReads(lessonInfo: lessonInfo.object)
                hasCache = true
            }
        }
        
        API.session.request(url).responseDecodable(of: LessonInfo.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let lessonInfo = response.value else {
                self.presenter?.onError(response.error)
                return
            }
            self.presenter?.didRetrieveLessonInfo(lessonInfo: lessonInfo)
            try? self.lessonInfoStorage?.setObject(lessonInfo, forKey: url)
            if !hasCache { self.retrieveReads(lessonInfo: lessonInfo) }
        }
    }

    private func retrieveReads(lessonInfo: LessonInfo) {
        self.ticker = lessonInfo.days.count
        dispatchQueue.async {
            lessonInfo.days.forEach { (day) in
                self.ticker = self.ticker - 1
                self.retrieveRead(readIndex: day.index)
                self.semaphore.wait()
            }
            
            lessonInfo.days.forEach { (day) in
                self.retrieveHighlights(readIndex: day.index)
            }
            
            lessonInfo.days.forEach { (day) in
                self.retrieveComments(readIndex: day.index)
            }
        }
    }

    func retrieveRead(readIndex: String) {
        let parsedIndex =  Helper.parseIndex(index: readIndex)
        let url = "\(Constants.API.URL)/\(parsedIndex.lang)/quarterlies/\(parsedIndex.quarter)/lessons/\(parsedIndex.week)/days/\(parsedIndex.day)/read/index.json"
        
        if (try? self.readStorage?.existsObject(forKey: url)) != nil {
            if let read = try? self.readStorage?.entry(forKey: url) {
                self.presenter?.didRetrieveRead(read: read.object, ticker: self.ticker)
            }
        }
        
        API.session.request(url)
            .responseDecodable(of: Read.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let read = response.value else {
                self.presenter?.onError(response.error)
                self.semaphore.signal()
                return
            }
            
            self.presenter?.didRetrieveRead(
                read: read,
                ticker: self.ticker
            )
            try? self.readStorage?.setObject(read, forKey: url)
            self.semaphore.signal()
        }
    }
    
    func retrieveAudio(quarterlyIndex: String) {
        let audioInteractor = AudioInteractor()
        
        audioInteractor.retrieveAudio(quarterlyIndex: quarterlyIndex) { audio in
            self.presenter?.didRetrieveAudio(audio: audio)
        }
    }
    
    func retrieveVideo(quarterlyIndex: String) {
        let videoInteractor = VideoInteractor()
        
        videoInteractor.retrieveVideo(quarterlyIndex: quarterlyIndex) { video in
            self.presenter?.didRetrieveVideo(video: video)
        }
    }

    func retrieveHighlights(readIndex: String) {
        API.auth.request("\(Constants.API.URL)/highlights/\(readIndex)")
            .customValidate()
            .responseDecodable(of: ReadHighlights.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let readHighlights = response.value else {
                self.presenter?.didRetrieveHighlights(highlights: ReadHighlights(readIndex: readIndex, highlights: ""))
                return
            }
            self.presenter?.didRetrieveHighlights(highlights: readHighlights)
        }
    }

    func retrieveComments(readIndex: String) {
        API.auth.request("\(Constants.API.URL)/comments/\(readIndex)")
            .customValidate()
            .responseDecodable(of: ReadComments.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let readComments = response.value else {
                self.presenter?.didRetrieveComments(comments: ReadComments(readIndex: readIndex, comments: [Comment]()))
                return
            }
            self.presenter?.didRetrieveComments(comments: readComments)
        }
    }

    func saveHighlights(highlights: ReadHighlights) {
        do {
            let wrappedHighlights = try JSONSerialization.jsonObject(with: JSONEncoder().encode(highlights), options: .allowFragments) as! [String: Any]
            
            API.auth.request(
                "\(Constants.API.URL)/highlights",
                method: .post,
                parameters: wrappedHighlights,
                encoding: JSONEncoding.default
            )
            .customValidate()
            .responseDecodable(of: String.self) { response in
                // Detect bad token to refresh potentially
            }
        } catch let error {
            self.presenter?.onError(error)
        }
    }

    func saveComments(comments: ReadComments) {
        do {
            let wrappedComments = try JSONSerialization.jsonObject(with: JSONEncoder().encode(comments), options: .allowFragments) as! [String: Any]
            
            API.auth.request(
                "\(Constants.API.URL)/comments",
                method: .post,
                parameters: wrappedComments,
                encoding: JSONEncoding.default
            )
            .customValidate()
            .responseDecodable(of: String.self) { response in }
        } catch let error {
            self.presenter?.onError(error)
        }
    }
    
    private func checkifReaderBundleNeeded() {
        API.session.request("\(Constants.API.HOST)/reader/\(Constants.API.READER_BUNDLE_FILENAME)", method: .head).responseData { response in
            if let lastModified = response.response?.allHeaderFields["Last-Modified"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss ZZZ"
                let date = dateFormatter.date(from: lastModified)
                if let timeInterval = date?.timeIntervalSince1970 {
                    if (String(format: "%f", timeInterval) != Preferences.latestReaderBundleTimestamp()) {
                        self.downloadReaderBundle(timeInterval: String(format: "%f", timeInterval))
                    }
                }
            }
        }
    }

    private func downloadReaderBundle(timeInterval: String) {
        var localURL = Constants.Path.readerBundleZip
        
        let destination: DownloadRequest.Destination = { _, _ in
            return (Constants.Path.readerBundleZip, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        API.session.download("\(Constants.API.HOST)/reader/\(Constants.API.READER_BUNDLE_FILENAME)", to: destination)
            .response { response in
            if response.error == nil {
                do {
                    Preferences.userDefaults.set(timeInterval, forKey: Constants.DefaultKey.latestReaderBundleTimestamp)
                    var unzipDirectory = try Zip.quickUnzipFile(localURL)
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try localURL.setResourceValues(resourceValues)
                    try unzipDirectory.setResourceValues(resourceValues)
                    FontBlaster.blast()
                } catch {
                    print("unzipping error")
                }
            }
        }
    }
}
