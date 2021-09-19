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

import Foundation

class Downloader: NSObject {
    let progress = Progress(totalUnitCount: 100)
    let downloadProgress = Progress(totalUnitCount: 1)
    let moveProgress = Progress(totalUnitCount: 1)

    let destinationFileURL: URL
    let remoteURL: URL

    var session: URLSession?
    var task: URLSessionDownloadTask?

    var didFinishDownloading: ((_ location: URL) -> Void)?

    init(remoteURL: URL, destinationFileURL: URL) {
        self.remoteURL = remoteURL
        self.destinationFileURL = destinationFileURL

        super.init()

        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        self.session = session
        let task = session.downloadTask(with: remoteURL)
        self.task = task
        task.resume()

        progress.addChild(downloadProgress, withPendingUnitCount: 99)
        progress.addChild(moveProgress, withPendingUnitCount: 1)
    }
}

extension Downloader: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager().moveItem(at: location, to: destinationFileURL)
            moveProgress.completedUnitCount = moveProgress.totalUnitCount
            didFinishDownloading?(location)
        } catch {
            print(error)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadProgress.totalUnitCount = totalBytesExpectedToWrite
        downloadProgress.completedUnitCount = totalBytesWritten
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            // Complete the progress.
            progress.completedUnitCount = progress.totalUnitCount
        }
    }
}
