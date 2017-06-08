//
//  LessonInteractor.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-05-30.
//  Copyright © 2017 Adventech. All rights reserved.
//

import Unbox

class LessonInteractor: FirebaseDatabaseInteractor, LessonInteractorInputProtocol {
    weak var presenter: LessonInteractorOutputProtocol?
    
    func retrieveQuarterlyInfo(quarterlyIndex: String) {
        database.child(Constants.Firebase.quarterlyInfo).child(quarterlyIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
            
            do {
                let item: QuarterlyInfo = try unbox(dictionary: json)
                
                self.saveLastQuarterlyIndex(lastQuarterlyIndex: quarterlyIndex)
                self.presenter?.didRetrieveQuarterlyInfo(quarterlyInfo: item)
            } catch let error {
                self.presenter?.onError(error)
            }
        }) { (error) in
            self.presenter?.onError(error)
        }
    }
    
    func saveLastQuarterlyIndex(lastQuarterlyIndex: String){
        UserDefaults.standard.set(lastQuarterlyIndex, forKey: Constants.DefaultKey.lastQuarterlyIndex)
    }
}
