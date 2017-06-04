//
//  ReadInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-31.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

class ReadInteractor: FirebaseDatabaseInteractor, ReadInteractorInputProtocol {
    weak var presenter: ReadInteractorOutputProtocol?
    
    private func retrieveReads(lessonInfo: LessonInfo){
        lessonInfo.days.forEach { (day) in
            retrieveRead(readIndex: day.index)
        }
    }
    
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
    
    func retrieveRead(readIndex: String) {
        database.child(Constants.Firebase.reads).child(readIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
                
            do {
                let item: Read = try unbox(dictionary: json)
                self.presenter?.didRetrieveRead(read: item)
            } catch let error {
                self.presenter?.onError(error)
            }
        }) { (error) in
            self.presenter?.onError(error)
        }
    }
}
