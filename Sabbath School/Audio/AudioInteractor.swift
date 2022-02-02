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
import Cache

class AudioInteractor {
    private var audioStorage: Storage<String, [Audio]>?
    
    init() {
        self.configure()
    }
    
    func configure() {
        self.audioStorage = APICache.storage?.transformCodable(ofType: [Audio].self)
    }
    
    func retrieveAudio(quarterlyIndex: String, cb: @escaping ([Audio]) -> Void) {
        let parsedIndex =  Helper.parseIndex(index: quarterlyIndex)
        let url = "\(Constants.API.HOST)/\(parsedIndex.lang)/quarterlies/\(parsedIndex.quarter)/audio.json"
        
        if (try? self.audioStorage?.existsObject(forKey: url)) != nil {
            if let audio = try? self.audioStorage?.entry(forKey: url) {
                cb(audio.object)
            }
        }
        
        API.session.request(url).responseDecodable(of: [Audio].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let audio = response.value else {
                return
            }
            cb(audio)
            try? self.audioStorage?.setObject(audio, forKey: url)
        }
    }
}
