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

import Cache

class DevotionalInteractor {
    private var devotionalResourceFeedStorage: Storage<String, [ResourceFeed]>?
    private var devotionalResourceDetailStorage: Storage<String, Resource>?
    private var devotionalResourceDocumentStorage: Storage<String, SSPMDocument>?
    
    init() {
        self.configure()
    }
    
    func configure() {
        self.devotionalResourceFeedStorage = APICache.storage?.transformCodable(ofType: [ResourceFeed].self)
        self.devotionalResourceDetailStorage = APICache.storage?.transformCodable(ofType: Resource.self)
    }
    
    func retrieveFeed(devotionalType: DevotionalType, language: String, cb: @escaping ([ResourceFeed]) -> Void) {
        let url = "\(Constants.API.URL)/\(language)/\(devotionalType)/index.json"
        if (try? self.devotionalResourceFeedStorage?.existsObject(forKey: url)) != nil {
            if let devotionalResources = try? self.devotionalResourceFeedStorage?.entry(forKey: url) {
                cb(devotionalResources.object)
            }
        }
        API.session.request(url).responseDecodable(of: [ResourceFeed].self, decoder: JSONDecoder()) { response in
            guard let resources = response.value else {
                return
            }
            cb(resources)
            try? self.devotionalResourceFeedStorage?.setObject(resources, forKey: url)
        }
    }
    
    func retrieveResource(index: String, cb: @escaping (Resource) -> Void) {
        let url = "\(Constants.API.URL)/\(index)/sections/index.json"
        if (try? self.devotionalResourceDetailStorage?.existsObject(forKey: url)) != nil {
            if let devotionalResource = try? self.devotionalResourceDetailStorage?.entry(forKey: url) {
                cb(devotionalResource.object)
            }
        }
        API.session.request(url).responseDecodable(of: Resource.self, decoder: JSONDecoder()) { response in
            guard let resource = response.value else {
                return
            }
            cb(resource)
            try? self.devotionalResourceDetailStorage?.setObject(resource, forKey: url)
        }
    }
    
    func retrieveDocument(index: String, cb: @escaping (SSPMDocument) -> Void) {
        let url = "\(Constants.API.URL)/\(index)/index.json"
        if (try? self.devotionalResourceDocumentStorage?.existsObject(forKey: url)) != nil {
            if let devotionalResourceDocument = try? self.devotionalResourceDocumentStorage?.entry(forKey: url) {
                cb(devotionalResourceDocument.object)
            }
        }
        API.session.request(url).responseDecodable(of: SSPMDocument.self, decoder: JSONDecoder()) { response in
            guard let resource = response.value else {
                return
            }
            cb(resource)
            try? self.devotionalResourceDocumentStorage?.setObject(resource, forKey: url)
        }
    }
}
