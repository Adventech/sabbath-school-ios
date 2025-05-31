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

import Alamofire
import Foundation
import Cache
import SwiftUI

@MainActor class ResourceViewModel: ObservableObject {
    @Published var resource: Resource? = nil
    @Published var fontsDownloaded: Bool = false
    @Published var readButtonDocumentIndex: String? = nil
    @Published var readButtonDocumentTitle: String? = nil
    @Published var readButtonSection: ResourceSection? = nil
    
    @Published var resourceProgress: [DocumentProgress] = []
    
    private static var resourceStorage: Storage<String, Resource>?
    private static var progressStorage: Storage<String, [DocumentProgress]>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        ResourceViewModel.resourceStorage = APICache.storage?.transformCodable(ofType: Resource.self)
        ResourceViewModel.progressStorage = APICache.storage?.transformCodable(ofType: [DocumentProgress].self)
    }
    
    func downloadFont(from url: URL, completion: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            completion(destinationURL)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            do {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

                guard let location = location, error == nil else {
                    completion(nil)
                    return
                }
                
                try fileManager.moveItem(at: location, to: destinationURL)
                completion(destinationURL)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func registerFont(with url: URL) {
        guard let fontFile = NSData(contentsOf: url) else {
            return
        }

        guard let provider = CGDataProvider(data: fontFile) else {
            return
        }

        let font = CGFont(provider)
        let error: UnsafeMutablePointer<Unmanaged<CFError>?>? = nil

        guard CTFontManagerRegisterGraphicsFont(font!, error) else {
            guard let unError = error?.pointee?.takeUnretainedValue(),
                  let _ = CFErrorCopyDescription(unError) else {
                return
            }
        }
    }
    
    func downloadFonts(resourceIndex: String) async {
        await self.retrieveResource(resourceIndex: resourceIndex)
        self.setReadDocumentIndex()
        
        guard let resource = self.resource else {
            self.fontsDownloaded = true
            return
        }
       
        if let fonts = resource.fonts {
            await downloadAndRegisterFonts(fontURLs: fonts.map { $0.src })
        }
        self.fontsDownloaded = true
    }

    func downloadAndRegisterFonts(fontURLs: [URL]) async {
        for fontURL in fontURLs {
            downloadFont(from: fontURL) { localURL in
                guard let localURL = localURL else {
                    return
                }
                self.registerFont(with: localURL)
            }
        }
    }
    
    func retrieveResource(resourceIndex: String) async {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/sections/index.json"
        
        if let exists = try? ResourceViewModel.resourceStorage?.existsObject(forKey: url), exists {
            if let resourceEntry = try? ResourceViewModel.resourceStorage?.entry(forKey: url) {
                self.resource = resourceEntry.object
            }
        }
        
        do {
            let resource = try await withCheckedThrowingContinuation { continuation in
                API.session.request(url).responseDecodable(of: Resource.self, decoder: Helper.SSJSONDecoder()) { response in
                    if let resource = response.value {
                        continuation.resume(returning: resource)
                    } else if let error = response.error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                }
            }
            
            self.resource = resource
            try? ResourceViewModel.resourceStorage?.setObject(resource, forKey: url)
        } catch {}
    }
    
    func retrieveProgress(completion: (() -> Void)? = nil) async {
        guard let resource = self.resource else {
            return
        }
        
        let url = "\(Constants.API.URLv3)/resources/user/progress/resource/\(resource.id)"
        
        
        if (try? ResourceViewModel.progressStorage?.existsObject(forKey: url)) != nil {
            if let resourceProgress = try? ResourceViewModel.progressStorage?.entry(forKey: url) {
                self.resourceProgress = resourceProgress.object
                completion?()
            }
        }
        
        API.auth.request(url)
            .customValidate()
            .responseDecodable(of: [DocumentProgress].self, decoder: Helper.SSJSONDecoder()) { response in
                guard let resourceProgress = response.value else {
                    completion?()
                    return
                }
                self.resourceProgress = resourceProgress
                try? ResourceViewModel.progressStorage?.setObject(resourceProgress, forKey: url)
                completion?()
        }
    }
    
    func saveProgress(documentId: String, force: Bool = false, completion: (() -> Void)? = nil) async {
        guard let resource = self.resource else {
            return
        }
        
        if resource.progressTracking == .manual && !force {
            return
        }
        
        let url = "\(Constants.API.URLv3)/resources/user/progress/\(resource.id)/\(documentId)"
        
        do {
            let savedProgress = DocumentProgress(documentId: documentId, completed: true)
            
            if !resourceProgress.contains(where: { $0.documentId == documentId && $0.completed }) {
                resourceProgress.append(savedProgress)
            }
            
            let userProgress = try JSONSerialization.jsonObject(with: JSONEncoder().encode(
                savedProgress
            ), options: .allowFragments) as! [String: Any]
            
            API.auth.request(
                url,
                method: .post,
                parameters: userProgress,
                encoding: JSONEncoding.default
            )
            .responseDecodable(of: String.self, decoder: Helper.SSJSONDecoder()) { response in }
        } catch let error {
            print("SSDEBUG", error)
        }
    }
    
    func setReadDocumentIndex () {
        if let sections = self.resource?.sections {
            var today = Date()
            let weekday = Calendar.current.component(.weekday, from: today)
            let hour = Calendar.current.component(.hour, from: today)
            var dateBasedSelected: Bool = false
            var progressBasedDocument: ResourceDocument? = nil
            var progressBasedSection: ResourceSection? = nil
            
            if (weekday == 7 && hour < 12 && self.resource?.type == .ss) {
                today = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
            }
            
            sections.forEach { section in
                section.documents.forEach { document in
                    if let startDate = document.startDate,
                       let endDate = document.endDate
                    {
                        let start = Calendar.current.compare(startDate.date, to: today, toGranularity: .day)
                        let end = Calendar.current.compare(endDate.date, to: today, toGranularity: .day)
                        
                        let fallsBetween = ((start == .orderedAscending) || (start == .orderedSame)) && ((end == .orderedDescending) || (end == .orderedSame))

                        if fallsBetween {
                            setReadButtonDocumentIndex(document: document, section: section)
                            dateBasedSelected = true
                        }
                    }
                    
                    if !resourceProgress.contains(where: { $0.documentId == document.id && $0.completed }) {
                        if progressBasedDocument == nil {
                            progressBasedDocument = document
                            progressBasedSection = section
                        } else {
                        }
                    } else {
                        progressBasedDocument = nil
                    }
                }
            }
            
            if let progressBasedDocument, !dateBasedSelected, resource?.progressTracking == .manual {
                setReadButtonDocumentIndex(document: progressBasedDocument, section: progressBasedSection)
            }
        }
    }
    
    private func setReadButtonDocumentIndex(document: ResourceDocument?, section: ResourceSection?) {
        self.readButtonDocumentIndex = document?.index
        self.readButtonDocumentTitle = document?.title
        self.readButtonSection = section
    }
}
