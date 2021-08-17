/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
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

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }

    func base64Decode() -> String? {
        guard let decodedData = Data(base64Encoded: self, options: Data.Base64DecodingOptions.init(rawValue: 0)) else {
            return nil
        }

        guard let decodedString = String(data: decodedData, encoding: String.Encoding.utf8) else {
            return nil
        }

        return decodedString
    }

    func base64Encode() -> String? {
        return Data(self.utf8).base64EncodedString()
    }
    
    func formatTimeDroppingLeadingZeros () -> String {
        return self.hasPrefix("0") && self.count > 4 ? .init(self.dropFirst()) : self
    }
}
