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

import Foundation

struct LocalUserInput: Codable {
    let id: String
    var synced: Bool
    let userInput: AnyUserInput

    init(
        id: String = UUID().uuidString,
        synced: Bool = false,
        userInput: AnyUserInput
    ) {
        self.id = id
        self.synced = synced
        self.userInput = userInput
    }

    func shouldBePreserved(over remoteUserInput: AnyUserInput) -> Bool {
        guard userInput.blockId == remoteUserInput.blockId,
              userInput.inputType == remoteUserInput.inputType else {
            return false
        }

        // A dirty local row is the only unacknowledged copy and must survive a fetch.
        if synced == false {
            return true
        }

        // Equality cannot prove that a second-resolution remote response is newer.
        return userInput.timestampInMilliseconds >= remoteUserInput.timestampInMilliseconds
    }
}
