/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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
import Alamofire
import SwiftUI
import SDWebImageWebPCoder
import Combine
import Cache

class DataProvider: ObservableObject {
    
    @Published var sections = [VideoSection]()
    @Published var languages = [Language]()
    private var videosStorage: Storage<String, [VideoJSON]>?
    private var languageStorage: Storage<String, [String]>?
    
    init() {
        APICache.configure()
        videosStorage = APICache.storage?.transformCodable(ofType: [VideoJSON].self)
        languageStorage = APICache.storage?.transformCodable(ofType: [String].self)
        
        setupImageCache()
    }
    
    private func setupImageCache() {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
        SDWebImageDownloader.shared.setValue("image/webp,image/*,*/*;q=0.8", forHTTPHeaderField:"Accept")
    }
    
    private func getSelectedLanguageCode() -> String {
        let selectedLanguage = UserDefaults.standard.string(forKey: "languageCode")
        
        if let selectedLanguage {
            return selectedLanguage
        }
        
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    func loadVideos() {
        let url = "\(Constants.API.URL)/\(getSelectedLanguageCode())/video/latest.json"
        
        if let videos = try? videosStorage?.entry(forKey: url) {
            var publishedVideos = [VideoSection]()
            
            videos.object.forEach { video in
                publishedVideos.append(VideoSection(video: video))
            }
            
            self.sections = publishedVideos
        }
        
        API.session.request(url).responseDecodable(of: [VideoJSON].self, decoder: Helper.SSJSONDecoder()) { response in
            
            guard let videos = response.value else {
                return
            }
            
            var publishedVideos = [VideoSection]()
            
            videos.forEach { video in
                publishedVideos.append(VideoSection(video: video))
            }
            
            if publishedVideos != self.sections {
                self.sections = publishedVideos
                
                do {
                    try self.videosStorage?.setObject(videos, forKey: url)
                } catch { }
            }
        }
    }
    
    func loadLanguages() {
        func transformLanguages(_ languages: [String]) -> [Language] {
            var publishedLanguages = [Language]()
            
            languages.forEach { code in
                
                let locale = Locale(identifier: code)
                let currentLocale = Locale.current
                let name = locale.localizedString(forLanguageCode: code)?.capitalized ?? "".capitalized
                let translatedName = currentLocale.localizedString(forLanguageCode: code)?.capitalized ?? "".capitalized
                
                let language = Language(id: code, name: name, translatedName: translatedName, isSelected: selectedLanguage == code)
                publishedLanguages.append(language)
                
                self.languages = publishedLanguages
            }
            
            return publishedLanguages
        }
        
        let url = "\(Constants.API.URL)/video/languages.json"
        
        let selectedLanguage = self.getSelectedLanguageCode()
        
        if let languages = try? languageStorage?.entry(forKey: url) {
            self.languages = transformLanguages(languages.object)
        }
        
        API.session.request(url).responseDecodable(of: [String].self, decoder: Helper.SSJSONDecoder()) { response in
            
            guard let languages = response.value else {
                return
            }
            
            var publishedLanguages = transformLanguages(languages)

            if self.languages != publishedLanguages {
                self.languages = publishedLanguages
                
                do {
                    try self.languageStorage?.setObject(languages, forKey: url)
                } catch { }
            }
        }
    }
}
