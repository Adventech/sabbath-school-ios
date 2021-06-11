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

import Foundation

class LessonInteractor: FirebaseDatabaseInteractor, LessonInteractorInputProtocol {
    weak var presenter: LessonInteractorOutputProtocol?

    func retrieveQuarterlyInfo(quarterlyIndex: String) {
        database?.child(Constants.Firebase.quarterlyInfo).child(quarterlyIndex).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let json = snapshot.data else { return }

            do {
                let item: QuarterlyInfo = try FirebaseDecoder().decode(QuarterlyInfo.self, from: json)

                self?.saveLastQuarterlyIndex(lastQuarterlyIndex: quarterlyIndex)
                self?.presenter?.didRetrieveQuarterlyInfo(quarterlyInfo: item)
            } catch let error {
                self?.presenter?.onError(error)
            }
        }) { [weak self] (error) in
            self?.presenter?.onError(error)
        }
    }

    func saveLastQuarterlyIndex(lastQuarterlyIndex: String) {
        UserDefaults.standard.set(lastQuarterlyIndex, forKey: Constants.DefaultKey.lastQuarterlyIndex)
    }
}
