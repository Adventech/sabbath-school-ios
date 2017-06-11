//
//  ReadInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import FirebaseAuth
import Unbox
import Wrap

class ReadInteractor: FirebaseDatabaseInteractor, ReadInteractorInputProtocol {
    weak var presenter: ReadInteractorOutputProtocol?
    
    func retrieveLessonInfo(lessonIndex: String){
        database.child(Constants.Firebase.lessonInfo).child(lessonIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
            
            do {
                let item: LessonInfo = try unbox(dictionary: json)
                self.presenter?.didRetrieveLessonInfo(lessonInfo: item)
                self.retrieveReads(lessonInfo: item)
            } catch let error {
                self.presenter?.onError(error)
            }
        }) { (error) in
            self.presenter?.onError(error)
        }
    }
    
    private func retrieveReads(lessonInfo: LessonInfo){
        lessonInfo.days.forEach { (day) in
            retrieveRead(readIndex: day.index)
        }
    }
    
    func retrieveRead(readIndex: String) {
        database.child(Constants.Firebase.reads).child(readIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
                
            do {
                let item: Read = try unbox(dictionary: json)
                self.retrieveHighlights(read: item)
            } catch let error {
                self.presenter?.onError(error)
            }
        }) { (error) in
            self.presenter?.onError(error)
        }
    }
    
    func retrieveHighlights(read: Read){
        database
            .child(Constants.Firebase.highlights)
            .child((Auth.auth().currentUser?.uid)!)
            .child(read.index).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let json = snapshot.value as? String else {
                    self.retrieveComments(read: read, highlights: ReadHighlights(readIndex: read.index, highlights: ""))
                    return
                }
                let item = ReadHighlights(readIndex: read.index, highlights: json)
                self.retrieveComments(read: read, highlights: item)
            }) { (error) in
                self.presenter?.onError(error)
            }
    }
    
    func retrieveComments(read: Read, highlights: ReadHighlights){
        database
            .child(Constants.Firebase.comments)
            .child((Auth.auth().currentUser?.uid)!)
            .child(read.index).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let json = snapshot.value as? [String: AnyObject] else {
                    self.presenter?.didRetrieveRead(read: read, highlights: highlights, comments: ReadComments(readIndex: read.index, comments: [Comment]()))
                    return
                }
                
                do {
                    let comments: ReadComments = try unbox(dictionary: json)
                    self.presenter?.didRetrieveRead(read: read, highlights: highlights, comments: comments)
                } catch let error {
                    self.presenter?.onError(error)
                }
            }) { (error) in
                self.presenter?.onError(error)
        }
    }
    
    func saveHighlights(read: Read, highlights: String){
        database.child(Constants.Firebase.highlights)
            .child((Auth.auth().currentUser?.uid)!)
            .child(read.index)
            .setValue(highlights)
    }
    
    func saveComments(comments: ReadComments){
        do {
            let wrappedComments: WrappedDictionary = try wrap(comments)
            database.child(Constants.Firebase.comments)
                .child((Auth.auth().currentUser?.uid)!)
                .child(comments.readIndex)
                .setValue(wrappedComments)
        } catch let error {
            self.presenter?.onError(error)
        }
    }
}
