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

import Alamofire
import Foundation

enum AuthenticationAction: Int {
    case refreshToken = 4010
    case logout = 4012
}

extension DataRequest {
    func customValidate() -> Self {
        return self.validate { request, response, data -> Request.ValidationResult in
            let statusCode = response.statusCode
            if statusCode != 401 {
                return .success(())
            } else {
                let authenticationAction = AuthenticationAction.refreshToken
                return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: authenticationAction.rawValue)))
            }
        }
    }
}

class APIRequestInterceptor: RequestInterceptor {
    let retryLimit = 3
    let retryDelay: TimeInterval = 2
    var isRetrying = false
    
    func adapt( _ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        guard let currentUser = PreferencesShared.currentUser() else {
            completion(.success(urlRequest))
            return
        }
        urlRequest.setValue(currentUser.stsTokenManager.accessToken, forHTTPHeaderField: "x-ss-auth-access-token")
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        if request.retryCount < self.retryLimit {
            if let statusCode = response?.statusCode, statusCode == 401, !isRetrying {
                self.isRetrying = true
                self.determineError(error: error, completion: completion)
            } else if (isRetrying) {
                completion(.retryWithDelay(self.retryDelay))
            } else {
                completion(.doNotRetry)
            }
        } else {
            API.auth.cancelAllRequests()
            completion(.doNotRetry)
        }
    }
        
    private func determineError(error: Error, completion: @escaping (RetryResult) -> Void) {
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(let reason):
                self.determineResponseValidationFailed(reason: reason, completion: completion)
            default:
                self.isRetrying = false
                completion(.retryWithDelay(self.retryDelay))
            }
        }
    }
        
    private func determineResponseValidationFailed(reason: AFError.ResponseValidationFailureReason, completion: @escaping (RetryResult) -> Void) {
        switch reason {
        case .unacceptableStatusCode(let code):
            switch code {
            case AuthenticationAction.refreshToken.rawValue:
                guard let currentUser = PreferencesShared.currentUser() else {
                    completion(.doNotRetry)
                    return
                }
                let wrappedUser = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(currentUser), options: .allowFragments) as? [String: Any]
                API.session.request(
                    "\(Constants.API.URL)/auth/refresh",
                    method: .post,
                    parameters: wrappedUser,
                    encoding: JSONEncoding.default
                ).responseDecodable(of: Account.self, decoder: Helper.SSJSONDecoder()) { response in
                    switch response.result {
                    case .success:
                        let dictionary = try! JSONEncoder().encode(response.value)
                        PreferencesShared.userDefaults.set(dictionary, forKey: Constants.DefaultKey.accountObject)
                        self.isRetrying = false
                        completion(.retryWithDelay(self.retryDelay))
                    case .failure:
                        // redirect to login page
                        self.isRetrying = false
                        completion(.doNotRetry)
                    }
                }
                break
            default:
                self.isRetrying = false
                API.session.cancelAllRequests()
                completion(.doNotRetry)
            }
        default:
            self.isRetrying = false
            completion(.retryWithDelay(self.retryDelay))
        }
    }
}

class API: NSObject {
    static let auth: Session = {
        let interceptor = APIRequestInterceptor()
        let configuration = URLSessionConfiguration.af.default
        configuration.urlCache = nil
        let responseCacher = ResponseCacher(behavior: .doNotCache)
        return Session(configuration: configuration, interceptor: interceptor, cachedResponseHandler: responseCacher)
    }()
    
    static let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        return Session.default
    }()
}
