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

import FirebaseAuth
import FirebaseStorage
import FontBlaster
import Zip

class ReadInteractor: FirebaseDatabaseInteractor, ReadInteractorInputProtocol {
    weak var presenter: ReadInteractorOutputProtocol?
    var ticker: Int = -1
    
    override func configure() {
        super.configure()
        checkifReaderBundleNeeded()
    }

    func retrieveLessonInfo(lessonIndex: String) {
        database?.child(Constants.Firebase.lessonInfo).child(lessonIndex).observe(.value, with: { [weak self] (snapshot) in
            guard let json = snapshot.data else { return }

            do {
                let item: LessonInfo = try FirebaseDecoder().decode(LessonInfo.self, from: json)
                self?.presenter?.didRetrieveLessonInfo(lessonInfo: item)
                self?.retrieveReads(lessonInfo: item)
            } catch let error {
                self?.presenter?.onError(error)
            }
        }) { [weak self] (error) in
            self?.presenter?.onError(error)
        }
    }

    private func retrieveReads(lessonInfo: LessonInfo) {
        self.ticker = lessonInfo.days.count

        lessonInfo.days.forEach { (day) in
            retrieveRead(readIndex: day.index)
        }
    }

    func retrieveRead(readIndex: String) {
        database?.child(Constants.Firebase.reads).child(readIndex).observe(.value, with: { [weak self] (snapshot) in
            guard let json = snapshot.data else { return }

            do {
                let item: Read = try FirebaseDecoder().decode(Read.self, from: json)
                self?.retrieveHighlights(read: item)
            } catch let error {
                self?.presenter?.onError(error)
            }
        }) { [weak self] (error) in
            self?.presenter?.onError(error)
        }
    }

    func retrieveHighlights(read: Read) {
        database?
            .child(Constants.Firebase.highlights)
            .child((Auth.auth().currentUser?.uid)!)
            .child(read.index).observe(.value, with: { [weak self] (snapshot) in
                guard let json = snapshot.data else {
                    self?.retrieveComments(read: read, highlights: ReadHighlights(readIndex: read.index, highlights: ""))
                    return
                }

                do {
                    let readHighlights = try FirebaseDecoder().decode(ReadHighlights.self, from: json)
                    self?.retrieveComments(read: read, highlights: readHighlights)
                } catch let error {
                    self?.presenter?.onError(error)
                }

            }) { [weak self] (error) in
                self?.presenter?.onError(error)
            }
    }

    func retrieveComments(read: Read, highlights: ReadHighlights) {
        database?
            .child(Constants.Firebase.comments)
            .child((Auth.auth().currentUser?.uid)!)
            .child(read.index).observe(.value, with: { [weak self] (snapshot) in
                self?.ticker = (self?.ticker)!-1
                guard let json = snapshot.data else {
                    self?.presenter?.didRetrieveRead(read: read, highlights: highlights, comments: ReadComments(readIndex: read.index, comments: [Comment]()), ticker: (self?.ticker)!)
                    return
                }

                do {
                    let comments = try FirebaseDecoder().decode(ReadComments.self, from: json)
                    self?.presenter?.didRetrieveRead(read: read, highlights: highlights, comments: comments, ticker: (self?.ticker)!)
                } catch let error {
                    self?.presenter?.onError(error)
                }
            }) { [weak self] (error) in
                self?.presenter?.onError(error)
        }
    }

    func saveHighlights(highlights: ReadHighlights) {
        do {
            let wrappedHighlights = try JSONSerialization.jsonObject(with: JSONEncoder().encode(highlights), options: .allowFragments) as! [String: Any]
            database?.child(Constants.Firebase.highlights)
                .child((Auth.auth().currentUser?.uid)!)
                .child(highlights.readIndex)
                .setValue(wrappedHighlights)
        } catch let error {
            self.presenter?.onError(error)
        }
    }

    func saveComments(comments: ReadComments) {
        do {
            
            let wrappedComments = try JSONSerialization.jsonObject(with: JSONEncoder().encode(comments), options: .allowFragments) as! [String: Any]
            database?.child(Constants.Firebase.comments)
                .child((Auth.auth().currentUser?.uid)!)
                .child(comments.readIndex)
                .setValue(wrappedComments)
        } catch let error {
            self.presenter?.onError(error)
        }
    }
    
    private func checkifReaderBundleNeeded() {
        let storage = Storage.storage()
        let gsReference = storage.reference(forURL: Constants.Firebase.Storage.ReaderPath.stage)

        gsReference.getMetadata { [weak self] (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if String(describing: metadata?.timeCreated?.timeIntervalSince1970) != Preferences.latestReaderBundleTimestamp() {
                    self?.downloadReaderBundle(metadata: metadata!)
                } else {}
            }
        }
    }

    private func downloadReaderBundle(metadata: StorageMetadata) {
        let storage = Storage.storage()
        let gsReference = storage.reference(forURL: Constants.Firebase.Storage.ReaderPath.stage)
        var localURL = Constants.Path.readerBundleZip

        _ = gsReference.write(toFile: localURL) { [weak self] (_, error) in
            if let error = error {
                self?.presenter?.onError(error)
            } else {
                do {
                    Preferences.userDefaults.set(String(describing: metadata.timeCreated?.timeIntervalSince1970), forKey: Constants.DefaultKey.latestReaderBundleTimestamp)
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
