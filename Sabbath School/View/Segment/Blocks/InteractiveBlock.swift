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
import SwiftUI

final class PendingUserInputSave: ObservableObject {
    private var timer: Timer?
    private var pendingSave: (() -> Void)?

    var hasPendingSave: Bool {
        pendingSave != nil
    }

    func schedule(after delay: TimeInterval, save: @escaping () -> Void) {
        timer?.invalidate()
        pendingSave = save
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.flush()
        }
    }

    @discardableResult
    func flush() -> Bool {
        timer?.invalidate()
        timer = nil

        guard let save = pendingSave else {
            return false
        }

        pendingSave = nil
        save()
        return true
    }

    deinit {
        timer?.invalidate()
    }
}

protocol InteractiveBlock: View where Body: View {
    var viewModel: DocumentViewModel { get }
    func loadInputData()
}

extension InteractiveBlock {
    @MainActor
    public func getUserInputForBlock(blockId: String, userInput: [AnyUserInput]?) -> AnyUserInput? {
        return (userInput ?? self.viewModel.documentUserInput).first(where: { $0.blockId == blockId })
    }
    
    @MainActor public func saveUserInput(_ userInput: AnyUserInput) {
        if viewModel.document != nil {
            viewModel.saveBlockUserInput(
                documentId: viewModel.document?.id,
                blockId: userInput.blockId,
                userInputType: userInput.inputType,
                userInput: userInput)
        }
    }
}
