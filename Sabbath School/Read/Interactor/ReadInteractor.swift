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
import Unbox
import Wrap

class ReadInteractor: FirebaseDatabaseInteractor, ReadInteractorInputProtocol {
    weak var presenter: ReadInteractorOutputProtocol?
    var ticker: Int = -1
    
    func retrieveLessonInfo(lessonIndex: String){
        database?.child(Constants.Firebase.lessonInfo).child(lessonIndex).observe(.value, with: { [weak self] (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
            
            do {
                let item: LessonInfo = try unbox(dictionary: json)
                self?.presenter?.didRetrieveLessonInfo(lessonInfo: item)
                self?.retrieveReads(lessonInfo: item)
            } catch let error {
                self?.presenter?.onError(error)
            }
        }) { [weak self] (error) in
            self?.presenter?.onError(error)
        }
    }
    
    private func retrieveReads(lessonInfo: LessonInfo){
        self.ticker = lessonInfo.days.count
        
        lessonInfo.days.forEach { (day) in
            retrieveRead(readIndex: day.index)
        }
    }
    
    func retrieveRead(readIndex: String) {
        database?.child(Constants.Firebase.reads).child(readIndex).observe(.value, with: { [weak self] (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
                
            do {
                let item: Read = try unbox(dictionary: json)
                self?.retrieveHighlights(read: item)
            } catch let error {
                self?.presenter?.onError(error)
            }
        }) { [weak self] (error) in
            self?.presenter?.onError(error)
        }
    }
    
    func retrieveHighlights(read: Read){
        database?
            .child(Constants.Firebase.highlights)
            .child((Auth.auth().currentUser?.uid)!)
            .child(read.index).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard let json = snapshot.value as? [String: AnyObject] else {
                    self?.retrieveComments(read: read, highlights: ReadHighlights(readIndex: read.index, highlights: ""))
                    return
                }
                
                do {
                    let readHighlights: ReadHighlights = try unbox(dictionary: json)
                    self?.retrieveComments(read: read, highlights: readHighlights)
                } catch let error {
                    self?.presenter?.onError(error)
                }
                
            }) { [weak self] (error) in
                self?.presenter?.onError(error)
            }
    }
    
    func retrieveComments(read: Read, highlights: ReadHighlights){
        database?
            .child(Constants.Firebase.comments)
            .child((Auth.auth().currentUser?.uid)!)
            .child(read.index).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                self?.ticker = (self?.ticker)!-1
                guard let json = snapshot.value as? [String: AnyObject] else {
                    self?.presenter?.didRetrieveRead(read: read, highlights: highlights, comments: ReadComments(readIndex: read.index, comments: [Comment]()), ticker: (self?.ticker)!)
                    return
                }
                
                do {
                    let comments: ReadComments = try unbox(dictionary: json)
                    
                    self?.presenter?.didRetrieveRead(read: read, highlights: highlights, comments: comments, ticker: (self?.ticker)!)
                } catch let error {
                    self?.presenter?.onError(error)
                }
            }) { [weak self] (error) in
                self?.presenter?.onError(error)
        }
    }
    
    func saveHighlights(highlights: ReadHighlights){
        do {
            let wrappedHighlights: WrappedDictionary = try wrap(highlights)
            database?.child(Constants.Firebase.highlights)
                .child((Auth.auth().currentUser?.uid)!)
                .child(highlights.readIndex)
                .setValue(wrappedHighlights)
        } catch let error {
            self.presenter?.onError(error)
        }
    }
    
    func saveComments(comments: ReadComments){
        do {
            let wrappedComments: WrappedDictionary = try wrap(comments)
            database?.child(Constants.Firebase.comments)
                .child((Auth.auth().currentUser?.uid)!)
                .child(comments.readIndex)
                .setValue(wrappedComments)
        } catch let error {
            self.presenter?.onError(error)
        }
    }
}
