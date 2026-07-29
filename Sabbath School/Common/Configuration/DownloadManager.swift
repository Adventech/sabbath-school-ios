/*
 * Copyright (c) 2025 Adventech <info@adventech.io>
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
import Foundation
import Nuke

enum DownloadItemStatus: String, Codable {
    case idle
    case downloading
}

struct DownloadItem: Codable {
    let resourceId: String
    let resourceIndex: String
    private var completed: Bool
    private var status: DownloadItemStatus
    private var attempts: Int
    
    init (resourceId: String, resourceIndex: String) {
        self.resourceId = resourceId
        self.resourceIndex = resourceIndex
        self.attempts = 0
        self.completed = false
        self.status = .idle
    }
    
    func isCompleted() -> Bool {
        return completed
    }
    
    mutating func incrementAttempts() {
        self.attempts += 1
    }
    
    mutating func markAsCompleted() {
        self.completed = true
    }
    
    func getStatus() -> DownloadItemStatus {
        return status
    }
    
    mutating func setStatus(status: DownloadItemStatus) {
        self.status = status
    }
}

class DownloadManager: ObservableObject {
    @Published private(set) var downloadItems: [String: DownloadItem] = [:]
    
    static let shared = DownloadManager()
    
    private var downloadKeys: [String] = []
    
    private let MAX_ATTEMPTS = 3
    private let KEYS_STORAGE = "ss_download_manager_keys"
    private static var downloadManagerStorage: Storage<String, DownloadItem>?
    private static var downloadManagerKeys: Storage<String, [String]>?
    private static var downloadManagerResourceStorage: Storage<String, Resource>?
    private static var downloadManagerDocumentStorage: Storage<String, ResourceDocument>?
    private static var downloadManagerSegmentStorage: Storage<String, Segment>?
    private static var downloadManagerPDFAuxStorage: Storage<String, [PDFAux]>?
    private static var downloadManagerVideoAuxStorage: Storage<String, [VideoAux]>?
    private static var downloadManagerAudioAuxStorage: Storage<String, [Audio]>?

    init () {
        DownloadManager.downloadManagerStorage = APICache.storage?.transformCodable(ofType: DownloadItem.self)
        DownloadManager.downloadManagerKeys = APICache.storage?.transformCodable(ofType: [String].self)
        DownloadManager.downloadManagerResourceStorage = APICache.storage?.transformCodable(ofType: Resource.self)
        DownloadManager.downloadManagerDocumentStorage = APICache.storage?.transformCodable(ofType: ResourceDocument.self)
        DownloadManager.downloadManagerSegmentStorage = APICache.storage?.transformCodable(ofType: Segment.self)
        DownloadManager.downloadManagerPDFAuxStorage = APICache.storage?.transformCodable(ofType: [PDFAux].self)
        DownloadManager.downloadManagerVideoAuxStorage = APICache.storage?.transformCodable(ofType: [VideoAux].self)
        DownloadManager.downloadManagerAudioAuxStorage = APICache.storage?.transformCodable(ofType: [Audio].self)
        loadFromCache()
    }
    
    private func loadFromCache() {
        guard let storage = DownloadManager.downloadManagerStorage else { return }
        guard let keysStorage = DownloadManager.downloadManagerKeys else { return }

        Task {
            if let allKeys = try? keysStorage.object(forKey: KEYS_STORAGE) {
                self.downloadKeys = allKeys
                var dict: [String: DownloadItem] = [:]
                for key in allKeys {
                    if var item = try? storage.object(forKey: key) {
                        if item.getStatus() == .downloading {
                            item.setStatus(status: .idle)
                            try? DownloadManager.downloadManagerStorage?.setObject(item, forKey: key)
                        }
                        dict[key] = item
                    }
                }
                DispatchQueue.main.async {
                    self.downloadItems = dict
                }
            }
        }
    }
    
    func download(resourceId: String, resourceIndex: String) {
        var downloadItem = DownloadItem(resourceId: resourceId, resourceIndex: resourceIndex)
        downloadItem.setStatus(status: .downloading)
        
        self.downloadKeys.append(resourceId)
        try? DownloadManager.downloadManagerStorage?.setObject(downloadItem, forKey: resourceId)
        try? DownloadManager.downloadManagerKeys?.setObject(downloadKeys, forKey: KEYS_STORAGE)
        
        DispatchQueue.main.async {
            self.downloadItems[resourceId] = downloadItem
        }
        
        Task {
            do {
                let resourceData = try await downloadResourceSections(resourceId: resourceId, resourceIndex: resourceIndex)
                
                guard let sections = resourceData.resource.sections else {
                    updateDownloadingsStatus(resourceId: resourceId, status: .idle)
                    return
                }
                
                try? DownloadManager.downloadManagerResourceStorage?.setObject(resourceData.resource, forKey: resourceData.url)
                
                
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        do {
                            let pdfAux = try await self.downloadPDFAux(resourceIndex: resourceIndex)
                            
                            try? DownloadManager.downloadManagerPDFAuxStorage?.setObject(pdfAux.pdfAux, forKey: pdfAux.url)
                            
                            for pdf in pdfAux.pdfAux {
                                let remoteURL = pdf.src
                                let fileName = pdf.id
                                let destinationFileURL = Helper.PDFDownloadFileURL(fileName: fileName)
                                
                                if !Helper.PDFDownloadFileExists(fileName: fileName) {
                                    _ = try await Downloader.download(remoteURL: remoteURL, destinationFileURL: destinationFileURL)
                                }
                            }
                        } catch {}
                    }
                    
                    group.addTask {
                        do {
                            let videoAuxData = try await self.downloadVideoAux(resourceIndex: resourceIndex)
                            
                            try? DownloadManager.downloadManagerVideoAuxStorage?.setObject(videoAuxData.videoAux, forKey: videoAuxData.url)
                        } catch {}
                    }
                    
                    group.addTask {
                        do {
                            let audioAuxData = try await self.downloadAudioAux(resourceIndex: resourceIndex)
                            
                            try? DownloadManager.downloadManagerAudioAuxStorage?.setObject(audioAuxData.audioAux, forKey: audioAuxData.url)
                        } catch {}
                    }
                    
                    for section in sections {
                        for document in section.documents {
                            group.addTask {
                                do {
                                    let documentData = try await self.downloadDocument(documentIndex: document.index)
                                    
                                    try? DownloadManager.downloadManagerDocumentStorage?.setObject(documentData.document, forKey: documentData.url)
                                    
                                    // Downloading cover image
                                    if let cover = document.cover {
                                        let imageTask = ImagePipeline.shared.imageTask(with: cover)
                                        _ = try await imageTask.image
                                    }
                                    
                                    // Downloading in case if segment has a specific cover image
                                    for segment in documentData.document.segments ?? [] {
                                        if let cover = segment.cover {
                                            let imageTask = ImagePipeline.shared.imageTask(with: cover)
                                            _ = try await imageTask.image
                                        }
                                        
                                        let hiddenSegments = segment.blocks?.filter({
                                            $0.type == .reference
                                            && $0.asType(Reference.self)?.scope == .segment
                                            && $0.asType(Reference.self)?.segment != nil
                                        }) ?? []
                                        
                                        for hiddenSegment in hiddenSegments {
                                            if let hiddenSegmentBlock = hiddenSegment.asType(Reference.self),
                                               let segmentIndex = hiddenSegmentBlock.segment?.index {
                                                let segmentData = try await self.downloadSegment(segmentIndex: segmentIndex)
                                                
                                                try? DownloadManager.downloadManagerSegmentStorage?.setObject(segmentData.segment, forKey: segmentData.url)
                                            }
                                            
                                        }
                                        
                                        // If segment type is .pdf then download all pdf files
                                        for pdf in segment.pdf ?? [] {
                                            let remoteURL = pdf.src
                                            let fileName = pdf.id
                                            let destinationFileURL = Helper.PDFDownloadFileURL(fileName: fileName)
                                            
                                            if !Helper.PDFDownloadFileExists(fileName: fileName) {
                                                _ = try await Downloader.download(remoteURL: remoteURL, destinationFileURL: destinationFileURL)
                                            }
                                        }
                                    }
                                } catch {
                                    self.updateDownloadingsStatus(resourceId: resourceId, status: .idle)
                                }
                            }
                        }
                    }
                }
                
                await MainActor.run {
                    self.markAsCompleted(resourceId: resourceId)
                    updateDownloadingsStatus(resourceId: resourceId, status: .idle)
                }
            } catch {
                updateDownloadingsStatus(resourceId: resourceId, status: .idle)
            }
        }
    }
    
    private func updateDownloadingsStatus(resourceId: String, status: DownloadItemStatus) {
        DispatchQueue.main.async {
            if var downloadItem = self.downloadItems[resourceId] {
                downloadItem.setStatus(status: status)
                self.downloadItems[resourceId] = downloadItem
                try? DownloadManager.downloadManagerStorage?.setObject(downloadItem, forKey: resourceId)
            }
        }
    }
    
    private func markAsCompleted(resourceId: String) {
        DispatchQueue.main.async {
            if var downloadItem = self.downloadItems[resourceId] {
                downloadItem.markAsCompleted()
                self.downloadItems[resourceId] = downloadItem
                try? DownloadManager.downloadManagerStorage?.setObject(downloadItem, forKey: resourceId)
            }
        }
    }
    
    private func downloadResourceSections(resourceId: String, resourceIndex: String) async throws -> (resource: Resource, url: String) {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/sections/index.json"
        
        return try await withCheckedThrowingContinuation { continuation in
            API.session.request(url).responseDecodable(of: Resource.self, decoder: Helper.SSJSONDecoder()) { response in
                if let resource = response.value {
                    continuation.resume(returning: (resource, url))
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
    
    private func downloadDocument(documentIndex: String) async throws -> (document: ResourceDocument, url: String) {
        let url = "\(Constants.API.URLv3)/\(documentIndex)/index.json"
        
        return try await withCheckedThrowingContinuation { continuation in
            API.session.request(url).responseDecodable(of: ResourceDocument.self, decoder: Helper.SSJSONDecoder()) { response in
                if let document = response.value {
                    continuation.resume(returning: (document, url))
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
    
    private func downloadSegment(segmentIndex: String) async throws -> (segment: Segment, url: String) {
        let url = "\(Constants.API.URLv3)/\(segmentIndex)/index.json"
        
        return try await withCheckedThrowingContinuation { continuation in
            API.session.request(url).responseDecodable(of: Segment.self, decoder: Helper.SSJSONDecoder()) { response in
                if let document = response.value {
                    continuation.resume(returning: (document, url))
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
    
    private func downloadPDFAux(resourceIndex: String) async throws -> (pdfAux: [PDFAux], url: String) {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/pdf.json"
        
        return try await withCheckedThrowingContinuation { continuation in
            API.session.request(url).responseDecodable(of: [PDFAux].self, decoder: Helper.SSJSONDecoder()) { response in
                if let pdfAux = response.value {
                    continuation.resume(returning: (pdfAux, url))
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
    
    private func downloadVideoAux(resourceIndex: String) async throws -> (videoAux: [VideoAux], url: String) {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/video.json"
        
        return try await withCheckedThrowingContinuation { continuation in
            API.session.request(url).responseDecodable(of: [VideoAux].self, decoder: Helper.SSJSONDecoder()) { response in
                if let videoAux = response.value {
                    continuation.resume(returning: (videoAux, url))
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
    
    private func downloadAudioAux(resourceIndex: String) async throws -> (audioAux: [Audio], url: String) {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/audio.json"
        
        return try await withCheckedThrowingContinuation { continuation in
            API.session.request(url).responseDecodable(of: [Audio].self, decoder: Helper.SSJSONDecoder()) { response in
                if let audioAux = response.value {
                    continuation.resume(returning: (audioAux, url))
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
    
    func removeDownload(resourceId: String, resourceIndex: String) {
        guard let storage = DownloadManager.downloadManagerStorage else { return }
        
        guard downloadItems[resourceId] != nil else { return }
        
        Task {
            try? storage.removeObject(forKey: resourceId)
            self.downloadKeys = self.downloadKeys.filter { $0 != resourceId }
            try? DownloadManager.downloadManagerKeys?.setObject(downloadKeys, forKey: KEYS_STORAGE)
            DispatchQueue.main.async {
                self.downloadItems.removeValue(forKey: resourceId)
            }
            
            let resourceURL = "\(Constants.API.URLv3)/\(resourceIndex)/sections/index.json"
            if let resource = try? DownloadManager.downloadManagerResourceStorage?.object(forKey: resourceURL) {
                for section in resource.sections ?? [] {
                    for document in section.documents {
                        for segment in document.segments ?? [] {
                            for pdf in segment.pdf ?? [] {
                                let fileName = pdf.id
                                let destinationFileURL = Helper.PDFDownloadFileURL(fileName: fileName)
                                Downloader.removeDownloadedFile(at: destinationFileURL)
                            }
                        }
                        
                        let documentURL = "\(Constants.API.URLv3)/\(document.index)/index.json"
                        try? DownloadManager.downloadManagerDocumentStorage?.removeObject(forKey: documentURL)
                    }
                }
                try? DownloadManager.downloadManagerResourceStorage?.removeObject(forKey: resourceURL)
            }
        }
    }
    
    public static func clearInMemoryDownloads() {
        DownloadManager.shared.downloadItems = [:]
        DownloadManager.shared.downloadKeys = []
    }

    public static func clearAllCache() {
        try? DownloadManager.downloadManagerStorage?.removeAll()
        try? DownloadManager.downloadManagerKeys?.removeAll()
        clearInMemoryDownloads()
    }
}
