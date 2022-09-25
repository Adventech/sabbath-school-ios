/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

struct Account: Codable {
    let uid: String
    let displayName: String?
    let email: String?
    let stsTokenManager: AccountToken
    let isAnonymous: Bool?
    
    init(uid: String, displayName: String?, email: String?, stsTokenManager: AccountToken, isAnonymous: Bool) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.stsTokenManager = stsTokenManager
        self.isAnonymous = isAnonymous
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uid = try values.decode(String.self, forKey: .uid)
        displayName = try? values.decode(String.self, forKey: .displayName)
        email = try? values.decode(String.self, forKey: .email)
        stsTokenManager = try values.decode(AccountToken.self, forKey: .stsTokenManager)
        isAnonymous = try? values.decode(Bool.self, forKey: .isAnonymous)
    }
}

class FIRUserTokenService: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    var refreshToken: String
    var accessToken: String
    
    func encode(with coder: NSCoder) {
        coder.encode(self.refreshToken, forKey: "refreshToken")
        coder.encode(self.accessToken, forKey: "accessToken")
    }

    required init?(coder aDecoder: NSCoder) {
        self.refreshToken = ""
        self.accessToken = ""
        
        if let refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as? String {
            self.refreshToken = refreshToken
        }
        if let accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String {
            self.accessToken = accessToken
        }
        
    }
}

class FIRUser: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    var tokenService: FIRUserTokenService?
    var apiKey: String
    var email: String?
    var displayName: String?
    var uid: String
    
    func encode(with coder: NSCoder) {
        coder.encode(self.tokenService, forKey: "tokenService")
        coder.encode(self.apiKey, forKey: "apiKey")
        coder.encode(self.uid, forKey: "uid")
    }

    required init?(coder aDecoder: NSCoder) {
        self.apiKey = ""
        self.uid = ""
        
        if let tokenService = try? aDecoder.decodeTopLevelObject(of: FIRUserTokenService.self, forKey: "tokenService") {
            self.tokenService = tokenService
        }
        if let apiKey = aDecoder.decodeObject(forKey: "APIKey") as? String {
            self.apiKey = apiKey
        }
        if let uid = aDecoder.decodeObject(forKey: "userID") as? String {
            self.uid = uid
        }
        if let email = aDecoder.decodeObject(forKey: "email") as? String {
            self.email = email
        }
        if let displayName = aDecoder.decodeObject(forKey: "displayName") as? String {
            self.displayName = displayName
        }
    }
}
