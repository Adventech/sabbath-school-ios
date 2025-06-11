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

final class SyncManager {
    private static var localInputStorage: Storage<String, [LocalUserInput]>?
    
    static let shared = SyncManager()
    
    private init() {
        self.configure()
    }
    
    func configure() {
        SyncManager.localInputStorage = APICache.storage?.transformCodable(ofType: [LocalUserInput].self)
    }
    
    func getLocalInput(documentIndex: String) -> [LocalUserInput] {
        guard let cached = (try? SyncManager.localInputStorage?.entry(forKey: documentIndex))?.object else {
            return []
        }
        
        return cached
    }
    
    func markAsSynced(documentIndex: String, localUserInputUUID: String) {
        if (try? SyncManager.localInputStorage?.existsObject(forKey: documentIndex)) != nil {
            if let localUserInputCached = try? SyncManager.localInputStorage?.entry(forKey: documentIndex) {
                var localUserInputsForDocument = localUserInputCached.object
                
                if let localUserInputIndex = localUserInputsForDocument.firstIndex(where: { $0.id == localUserInputUUID }) {
                    localUserInputsForDocument[localUserInputIndex].synced = true
                    
                    try? SyncManager.localInputStorage?.setObject(localUserInputsForDocument, forKey: documentIndex)
                }
            }
        }
    }
    
    func getAllUnsyncedLocalInputs(documentId: String) -> [LocalUserInput] {
        var unsyncedItems: [LocalUserInput] = []
        
        if (try? SyncManager.localInputStorage?.existsObject(forKey: documentId)) != nil {
            if let localUserInputCached = try? SyncManager.localInputStorage?.entry(forKey: documentId) {
                unsyncedItems = localUserInputCached.object.filter { $0.synced == false }
            }
        }
        
        return unsyncedItems
    }
    
    func saveLocalInput(documentIndex: String, userInput: AnyUserInput, syncStatus: Bool = false) -> LocalUserInput? {
        var localUserInput: [LocalUserInput]?
        
        if (try? SyncManager.localInputStorage?.existsObject(forKey: documentIndex)) != nil {
            if let localUserInputCached = try? SyncManager.localInputStorage?.entry(forKey: documentIndex) {
                localUserInput = localUserInputCached.object
            } else {
                localUserInput = []
            }
        } else {
            localUserInput = []
        }
        
        if var localUserInput = localUserInput {
            let localUserInputEntry = LocalUserInput(synced: syncStatus, userInput: userInput)
            
            if let existing = localUserInput.firstIndex(where: { $0.userInput.blockId == userInput.blockId && $0.userInput.inputType == userInput.inputType }) {
                localUserInput[existing] = localUserInputEntry
            } else {
                localUserInput.append(localUserInputEntry)
            }
            
            try? SyncManager.localInputStorage?.setObject(localUserInput, forKey: documentIndex)
            return localUserInputEntry
        }
        return nil
    }
    
    public static func clearAllCache() {
        try? SyncManager.localInputStorage?.removeAll()
    }
}
