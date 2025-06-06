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

struct SavedScrollOffset: Codable {
    let blockId: String
    let scrollOffset: CGFloat
}

@MainActor class DocumentViewModel: ObservableObject {
    @Published var document: ResourceDocument? = nil
    @Published var pdfAuxiliary: [PDFAux]? = nil
    @Published var videoAuxiliary: [VideoAux]? = nil
    @Published var audioAuxiliary: [Audio]? = nil
    
    @Published var documentUserInput: [AnyUserInput] = []
    @Published var selectedSegmentIndex: Int? = nil
    @Published var selectedSegmentName: String? = nil

    private static var documentStorage: Storage<String, ResourceDocument>?
    private static var segmentStorage: Storage<String, Segment>?
    public static var lastVisibleScrollOffset: Storage<String, SavedScrollOffset>?
    
    init() {
         self.configure()
    }
    
    public static func clearAllCache() {
        try? DocumentViewModel.documentStorage?.removeAll()
        try? DocumentViewModel.segmentStorage?.removeAll()
        try? DocumentViewModel.lastVisibleScrollOffset?.removeAll()
    }
    
    func configure() {
        DocumentViewModel.documentStorage = APICache.storage?.transformCodable(ofType: ResourceDocument.self)
        DocumentViewModel.segmentStorage = APICache.storage?.transformCodable(ofType: Segment.self)
        DocumentViewModel.lastVisibleScrollOffset = APICache.storage?.transformCodable(ofType: SavedScrollOffset.self)
    }
    
    func retrievePDFAux(resourceIndex: String, documentIndex: String) async {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/pdf.json"
        
        API.session.request(url).responseDecodable(of: [PDFAux].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let pdfAuxiliary = response.value else {
                return
            }
            self.pdfAuxiliary = pdfAuxiliary.filter { $0.target == documentIndex }
        }
    }
    
    func retrieveVideoAux(resourceIndex: String, documentIndex: String) async {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/video.json"
        
        API.session.request(url).responseDecodable(of: [VideoAux].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let videoAuxiliary = response.value else {
                return
            }
            self.videoAuxiliary = videoAuxiliary
        }
    }
    
    func retrieveAudioAux(resourceIndex: String, documentIndex: String) async {
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/audio.json"
        
        API.session.request(url).responseDecodable(of: [Audio].self, decoder: Helper.SSJSONDecoder()) { response in
            guard let audioAuxiliary = response.value else {
                return
            }

            self.audioAuxiliary = audioAuxiliary.filter { $0.targetIndex.starts(with: documentIndex) }
        }
    }
    
    func retrieveDocument(documentIndex: String, completion: (() -> Void)? = nil) async {
        let url = "\(Constants.API.URLv3)/\(documentIndex)/index.json"
        var completed = false
        
        if (try? DocumentViewModel.documentStorage?.existsObject(forKey: url)) != nil {
            if let document = try? DocumentViewModel.documentStorage?.entry(forKey: url) {
                self.document = document.object
                completed = true
                self.setSelectedSegmentIndex()
                completion?()
            }
        }
        API.session.request(url).responseDecodable(of: ResourceDocument.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let document = response.value else {
                return
            }
            self.document = document
            try? DocumentViewModel.documentStorage?.setObject(document, forKey: url)
            self.setSelectedSegmentIndex()
            if !completed { completion?() }
        }
    }
    
    func retrieveSegment(segmentIndex: String, completion: ((_ segment: Segment) -> Void)? = nil) async {
        let url = "\(Constants.API.URLv3)/\(segmentIndex)/index.json"
        
        if (try? DocumentViewModel.segmentStorage?.existsObject(forKey: url)) != nil {
            if let segment = try? DocumentViewModel.segmentStorage?.entry(forKey: url) {
                completion?(segment.object)
            }
        }
        API.session.request(url).responseDecodable(of: Segment.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let segment = response.value else {
                return
            }
            try? DocumentViewModel.segmentStorage?.setObject(segment, forKey: url)
            completion?(segment)
        }
    }
    
    func syncLocallySavedNotSyncedItems(documentId: String) {
        for localUserInput in SyncManager.shared.getAllUnsyncedLocalInputs(documentId: documentId) {
            do {
                let userInput = try JSONSerialization.jsonObject(with: JSONEncoder().encode(localUserInput.userInput), options: .allowFragments) as! [String: Any]
                
                API.auth.request(
                    "\(Constants.API.URLv3)/resources/user/input/\(localUserInput.userInput.inputType.rawValue)/\(documentId)/\(localUserInput.userInput.blockId)",
                    method: .post,
                    parameters: userInput,
                    encoding: JSONEncoding.default
                ).response { response in
                    if response.response?.statusCode == 200 {
                        SyncManager.shared.markAsSynced(documentIndex: documentId, localUserInputUUID: localUserInput.id)
                    }
                }
            } catch {}
        }
    }
    
    func retrieveDocumentUserInput(documentId: String) {
        self.documentUserInput = SyncManager.shared.getLocalInput(documentIndex: documentId).map { $0.userInput }
            
        API.auth.request("\(Constants.API.URLv3)/resources/user/input/document/\(documentId)")
            .customValidate()
            .responseDecodable(of: [AnyUserInput].self, decoder: Helper.SSJSONDecoder()) { response in
                guard let remoteUserInput = response.value else {
                    return
                }
                    
                let localUserInputForDocument = SyncManager.shared.getLocalInput(documentIndex: documentId)
                
                var mergedUserInput: [AnyUserInput] = []
                
                for userInput in remoteUserInput {
                    if let localUserInput = localUserInputForDocument.first(where: { $0.userInput.blockId == userInput.blockId && $0.userInput.inputType == userInput.inputType && ($0.userInput.timestamp > userInput.timestamp) }) {
                        mergedUserInput.append(localUserInput.userInput)
                    } else {
                        let _ = SyncManager.shared.saveLocalInput(documentIndex: documentId, userInput: userInput, syncStatus: true)
                        mergedUserInput.append(userInput)
                    }
                }
                
                // Show any other locally saved user input
                for userInput in localUserInputForDocument.map({ $0.userInput }) {
                    guard mergedUserInput.firstIndex(where: { $0.blockId == userInput.blockId && $0.inputType == userInput.inputType }) == nil else {
                        continue
                    }
                    
                    mergedUserInput.append(userInput)
                }
                    
                self.documentUserInput = mergedUserInput
                self.syncLocallySavedNotSyncedItems(documentId: documentId)
            }
    }
    
    func retrievePollData(pollId: String, completion: ((PollResults?) -> Void?)? = nil) async {
        API.auth.request("\(Constants.API.URLv3)/resources/polls/\(pollId)")
            .customValidate()
            .responseDecodable(of: PollResults.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let pollResults = response.value else {
                completion?(nil)
                return
            }
            completion?(pollResults)
        }
    }
    
    func saveBlockUserInput(documentId: String?, blockId: String, userInputType: UserInputType, userInput: AnyUserInput) {
        guard let documentId = documentId else {
            return
        }
        
        do {
            if let index = documentUserInput.firstIndex(where: { $0.blockId == userInput.blockId && $0.inputType == userInput.inputType }) {
                documentUserInput[index] = userInput
            } else {
                documentUserInput.append(userInput)
            }
            
            let localUserInputUUID = SyncManager.shared.saveLocalInput(documentIndex: documentId, userInput: userInput)
            
            let userInput = try JSONSerialization.jsonObject(with: JSONEncoder().encode(userInput), options: .allowFragments) as! [String: Any]
            
            API.auth.request(
                "\(Constants.API.URLv3)/resources/user/input/\(userInputType.rawValue)/\(documentId)/\(blockId)",
                method: .post,
                parameters: userInput,
                encoding: JSONEncoding.default
            ).response { response in
                if response.response?.statusCode == 200 {
                    if let localUserInputUUID = localUserInputUUID {
                        SyncManager.shared.markAsSynced(documentIndex: documentId, localUserInputUUID: localUserInputUUID.id)
                    }
                }
            }
        } catch let error {
            print("SSDEBUG", error)
        }
    }
    
    func setSelectedSegmentIndex() {
        if let segments = self.document?.segments {
            if let selectedSegmentName = selectedSegmentName {
                segments.enumerated().forEach { segmentIndex, segment in
                    if segment.name == selectedSegmentName {
                        self.selectedSegmentIndex = segmentIndex
                    }
                }
            }
            
            if self.selectedSegmentIndex != nil {
                return
            }
                
            let today = Date()
            let cal = Calendar.current
            
            segments.enumerated().forEach { segmentIndex, segment in
                if let segmentDate = segment.date,
                   self.selectedSegmentIndex == nil
                {
                    if cal.compare(today, to: segmentDate.date, toGranularity: .day) == .orderedSame {
                        self.selectedSegmentIndex = segmentIndex
                    }
                }
            }
            
            if self.selectedSegmentIndex == nil {
                self.selectedSegmentIndex = 0
            }
        }
    }
}
