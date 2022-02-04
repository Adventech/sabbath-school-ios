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
import Foundation
import Cache

class LessonInteractor: LessonInteractorInputProtocol {
    weak var presenter: LessonInteractorOutputProtocol?
    private var storage: Storage<String, QuarterlyInfo>?
    
    init () {
        self.configure()
    }
    
    func configure() {
        self.storage = APICache.storage?.transformCodable(ofType: QuarterlyInfo.self)
    }

    func retrieveQuarterlyInfo(quarterlyIndex: String) {
        let parsedIndex =  Helper.parseIndex(index: quarterlyIndex)
        let url = "\(Constants.API.URL)/\(parsedIndex.lang)/quarterlies/\(parsedIndex.quarter)/index.json"
        
        if (try? self.storage?.existsObject(forKey: url)) != nil {
            if let quarterlyInfo = try? self.storage?.entry(forKey: url) {
                self.presenter?.didRetrieveQuarterlyInfo(quarterlyInfo: quarterlyInfo.object)
            }
        }
        
        API.session.request(url).responseDecodable(of: QuarterlyInfo.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let quarterlyInfo = response.value else {
                self.presenter?.onError(response.error)
                return
            }
            self.presenter?.didRetrieveQuarterlyInfo(quarterlyInfo: quarterlyInfo)
            try? self.storage?.setObject(quarterlyInfo, forKey: url)
        }
    }

    func saveLastQuarterlyIndex(lastQuarterlyIndex: String) {
        Preferences.userDefaults.set(lastQuarterlyIndex, forKey: Constants.DefaultKey.lastQuarterlyIndex)
    }
}
