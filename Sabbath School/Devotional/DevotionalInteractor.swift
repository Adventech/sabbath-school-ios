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
    private static var devotionalResourceInfoStorage: Storage<String, [ResourceInfo]>?
    private static var devotionalResourceFeedStorage: Storage<String, [ResourceFeed]>?
    private static var devotionalResourceDetailStorage: Storage<String, Resource>?
    private static var devotionalResourceDocumentStorage: Storage<String, SSPMDocument>?
    
    init() {
        self.configure()
    }
    
    public var devotionalInfoEndpoint: String {
        return "\(Constants.API.URL)/resources/index.json"
    }
    
    public func devotionalResourceInfoExists(key: String) -> Bool {
        return (try? DevotionalInteractor.devotionalResourceFeedStorage?.existsObject(forKey: key)) != nil
    }
    
    public func getDevotionalResourceInfo(key: String) -> [ResourceInfo]? {
        if let devotionalResources = try? DevotionalInteractor.devotionalResourceInfoStorage?.entry(forKey: key) {
            return devotionalResources.object
        }
        return nil
    }
    
    func configure() {
        DevotionalInteractor.devotionalResourceInfoStorage = APICache.storage?.transformCodable(ofType: [ResourceInfo].self)
        DevotionalInteractor.devotionalResourceFeedStorage = APICache.storage?.transformCodable(ofType: [ResourceFeed].self)
        DevotionalInteractor.devotionalResourceDetailStorage = APICache.storage?.transformCodable(ofType: Resource.self)
        DevotionalInteractor.devotionalResourceDocumentStorage = APICache.storage?.transformCodable(ofType: SSPMDocument.self)
    }
    
    func retrieveResourceInfo() {
        let url = self.devotionalInfoEndpoint
        
        API.session.request(url).responseDecodable(of: [ResourceInfo].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let resourceInfo = response.value else {
                return
            }
            try? DevotionalInteractor.devotionalResourceInfoStorage?.setObject(resourceInfo, forKey: url)
        }
    }
    
    func retrieveFeed(devotionalType: DevotionalType, language: String, cb: @escaping ([ResourceFeed]) -> Void) {
        let url = "\(Constants.API.URL)/\(language)/\(devotionalType)/index.json"
        if (try? DevotionalInteractor.devotionalResourceFeedStorage?.existsObject(forKey: url)) != nil {
            if let devotionalResources = try? DevotionalInteractor.devotionalResourceFeedStorage?.entry(forKey: url) {
                cb(devotionalResources.object)
            }
        }
        API.session.request(url).responseDecodable(of: [ResourceFeed].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let resources = response.value else {
                return
            }
            cb(resources)
            try? DevotionalInteractor.devotionalResourceFeedStorage?.setObject(resources, forKey: url)
        }
    }
    
    func retrieveResource(index: String, cb: @escaping (Resource) -> Void) {
        let url = "\(Constants.API.URL)/\(index)/sections/index.json"
        if (try? DevotionalInteractor.devotionalResourceDetailStorage?.existsObject(forKey: url)) != nil {
            if let devotionalResource = try? DevotionalInteractor.devotionalResourceDetailStorage?.entry(forKey: url) {
                cb(devotionalResource.object)
            }
        }
        API.session.request(url).responseDecodable(of: Resource.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let resource = response.value else {
                print("SSDEBUG", response)
                return
            }
            cb(resource)
            try? DevotionalInteractor.devotionalResourceDetailStorage?.setObject(resource, forKey: url)
        }
    }
    
    func retrieveDocument(index: String, cb: @escaping (SSPMDocument) -> Void) {
        let url = "\(Constants.API.URL)/\(index)/index.json"
        if (try? DevotionalInteractor.devotionalResourceDocumentStorage?.existsObject(forKey: url)) != nil {
            if let devotionalResourceDocument = try? DevotionalInteractor.devotionalResourceDocumentStorage?.entry(forKey: url) {
                cb(devotionalResourceDocument.object)
            }
        }
        API.session.request(url).responseDecodable(of: SSPMDocument.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let resource = response.value else {
                print("SSDEBUG", url)
                print("SSDEBUG", response)
                return
            }
            cb(resource)
            try? DevotionalInteractor.devotionalResourceDocumentStorage?.setObject(resource, forKey: url)
        }
    }
    
    public static func removeAllCache() {
        try? DevotionalInteractor.devotionalResourceInfoStorage?.removeAll()
        try? DevotionalInteractor.devotionalResourceFeedStorage?.removeAll()
        try? DevotionalInteractor.devotionalResourceDetailStorage?.removeAll()
        try? DevotionalInteractor.devotionalResourceDocumentStorage?.removeAll()
    }
}
