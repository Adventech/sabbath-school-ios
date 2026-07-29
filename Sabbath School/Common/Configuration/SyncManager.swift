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
    private enum LocalInputPersistenceError: Error {
        case storageUnavailable
        case validationFailed
    }

    private static var localInputStorage: Storage<String, [LocalUserInput]>?
    private static let recoveryKeyPrefix = "__local_user_input_recovery_v1__:"

    private let persistenceQueue = DispatchQueue(label: "org.adventech.sabbath-school.local-input-persistence")
    
    static let shared = SyncManager()
    
    private init() {
        self.configure()
    }
    
    func configure() {
        SyncManager.localInputStorage = APICache.storage?.transformCodable(ofType: [LocalUserInput].self)
    }
    
    func getLocalInput(documentIndex: String) -> [LocalUserInput] {
        return persistenceQueue.sync {
            guard let storage = SyncManager.localInputStorage else {
                return []
            }

            let recoveryKey = self.recoveryKey(for: documentIndex)

            do {
                if let recoveredInput = try self.promotePendingRecovery(
                    for: documentIndex,
                    recoveryKey: recoveryKey,
                    using: storage
                ) {
                    return recoveredInput
                }
            } catch {
                // If promotion cannot finish, keep serving the durable sidecar.
                do {
                    if let pendingInput = try self.readStoredInput(forKey: recoveryKey, from: storage) {
                        return pendingInput
                    }
                } catch {
                    // An incomplete sidecar must not hide a readable canonical value.
                }
            }

            do {
                return try self.readStoredInput(forKey: documentIndex, from: storage) ?? []
            } catch {
                return []
            }
        }
    }
    
    func markAsSynced(documentIndex: String, localUserInputUUID: String) {
        persistenceQueue.sync {
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
    }
    
    func getAllUnsyncedLocalInputs(documentId: String) -> [LocalUserInput] {
        return getLocalInput(documentIndex: documentId).filter { $0.synced == false }
    }
    
    func saveLocalInput(documentIndex: String, userInput: AnyUserInput, syncStatus: Bool = false) throws -> LocalUserInput {
        return try persistenceQueue.sync {
            guard let storage = SyncManager.localInputStorage else {
                throw LocalInputPersistenceError.storageUnavailable
            }

            let recoveryKey = self.recoveryKey(for: documentIndex)
            let recoveredInputs = try self.promotePendingRecovery(
                for: documentIndex,
                recoveryKey: recoveryKey,
                using: storage
            )
            var updatedInputs = recoveredInputs ?? (try self.readStoredInput(forKey: documentIndex, from: storage) ?? [])
            let localUserInputEntry = LocalUserInput(synced: syncStatus, userInput: userInput)
            
            if let existing = updatedInputs.firstIndex(where: { $0.userInput.blockId == userInput.blockId && $0.userInput.inputType == userInput.inputType }) {
                updatedInputs[existing] = localUserInputEntry
            } else {
                updatedInputs.append(localUserInputEntry)
            }

            // Keep a complete validated snapshot while Cache replaces canonical data in place.
            try self.persistAndValidate(updatedInputs, forKey: recoveryKey, using: storage)
            try self.persistAndValidate(updatedInputs, forKey: documentIndex, using: storage)
            try storage.removeObject(forKey: recoveryKey)

            return localUserInputEntry
        }
    }

    private func recoveryKey(for documentIndex: String) -> String {
        return SyncManager.recoveryKeyPrefix + documentIndex
    }

    private func readStoredInput(
        forKey key: String,
        from storage: Storage<String, [LocalUserInput]>
    ) throws -> [LocalUserInput]? {
        do {
            return try storage.entry(forKey: key).object
        } catch StorageError.notFound {
            return nil
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            return nil
        }
    }

    private func encodedInputs(_ inputs: [LocalUserInput]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(inputs)
    }

    private func persistAndValidate(
        _ inputs: [LocalUserInput],
        forKey key: String,
        using storage: Storage<String, [LocalUserInput]>
    ) throws {
        do {
            try storage.setObject(inputs, forKey: key)
        } catch {
            let writeError = error
            try storage.removeInMemoryObject(forKey: key)
            throw writeError
        }

        // Cache writes memory first; evict it so validation must read disk.
        try storage.removeInMemoryObject(forKey: key)
        guard let storedInputs = try readStoredInput(forKey: key, from: storage),
              try encodedInputs(storedInputs) == encodedInputs(inputs) else {
            throw LocalInputPersistenceError.validationFailed
        }
    }

    private func promotePendingRecovery(
        for documentIndex: String,
        recoveryKey: String,
        using storage: Storage<String, [LocalUserInput]>
    ) throws -> [LocalUserInput]? {
        guard let pendingInputs = try readStoredInput(forKey: recoveryKey, from: storage) else {
            return nil
        }

        try persistAndValidate(pendingInputs, forKey: documentIndex, using: storage)
        try storage.removeObject(forKey: recoveryKey)
        return pendingInputs
    }
    
    public static func clearAllCache() {
        try? SyncManager.localInputStorage?.removeAll()
    }
}
