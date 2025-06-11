/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
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

@MainActor
class ResourceInfoViewModel: ObservableObject {
    @Published var resourceInfo: [ResourceInfo]? = nil
    @Published var resourceInfoForLanguage: ResourceInfo? = nil
    
    public static var resourceInfoStorage: Storage<String, [ResourceInfo]>?
    
    
    init() {
         self.configure()
    }
    
    func configure() {
        ResourceInfoViewModel.resourceInfoStorage = APICache.storage?.transformCodable(ofType: [ResourceInfo].self)
        
        if let existingResourceInfo = getResourceInfo() {
            resourceInfo = existingResourceInfo
        }
    }
    
    public static func clearAllCache() {
        try? ResourceInfoViewModel.resourceInfoStorage?.removeAll()
    }
    
    public var resourceInfoEndpoint: String {
        return "\(Constants.API.URLv3)/resources/index.json"
    }
    
    public func getResourceInfo() -> [ResourceInfo]? {
        if let resourceInfo = try? ResourceInfoViewModel.resourceInfoStorage?.entry(forKey: resourceInfoEndpoint) {
            return resourceInfo.object
        }
        return nil
    }
    
    func setResourceInfoForLanguage () {
        if let resourceInfo = resourceInfo {
            if let foundLanguage = resourceInfo.first(where: { $0.code == Preferences.currentLanguage().code} ) {
                resourceInfoForLanguage = foundLanguage
            } else {
                PreferencesShared.userDefaults.language = QuarterlyLanguage(code: "en", name: "English")
                resourceInfoForLanguage = ResourceInfo(code: "en", name: "English", ss: true, aij: true, pm: true, devo: true, explore: true)
            }
        }
    }
    
    func retrieveResourceInfo() async {
        let url = self.resourceInfoEndpoint
        
        if (try? ResourceInfoViewModel.resourceInfoStorage?.existsObject(forKey: url)) != nil {
            if let resourceInfo = try? ResourceInfoViewModel.resourceInfoStorage?.entry(forKey: url) {
                self.resourceInfo = resourceInfo.object
                setResourceInfoForLanguage()
            }
        }

        API.session.request(url).responseDecodable(of: [ResourceInfo].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let resourceInfo = response.value else {
                return
            }
            
            self.resourceInfo = resourceInfo
            self.setResourceInfoForLanguage()
            try? ResourceInfoViewModel.resourceInfoStorage?.setObject(resourceInfo, forKey: url)
        }
    }
}
