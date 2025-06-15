//
//  AuthAPI.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import Foundation
import Alamofire

class AuthAPI {
    /// Returns true if user has a valid access token stored
    var isLoggedIn: Bool {
        return KeychainService.shared.get("accessToken") != nil
    }
    static let shared = AuthAPI()
    private let baseURL = "https://zk-backend.onrender.com" // Change this to your API base URL

    // MARK: - Login
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL + "/auth/login"
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        print("[AuthAPI] Calling LOGIN: \(url)")
        print("[AuthAPI] Parameters: \(parameters)")
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                print("[AuthAPI] LOGIN response: \(String(describing: response.value))")
                switch response.result {
                case .success(let data):
                    // Try decode as success response first
                    if let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data),
                       let success = loginResponse.success, (success == .bool(true) || success == .int(1)) {
                        KeychainService.shared.set(loginResponse.data.token, forKey: "accessToken")
                        completion(.success(()))
                    } else if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                        let message = errorResponse.message ?? "Unknown error"
                        completion(.failure(NSError(domain: "AuthAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: message])))
                    } else {
                        completion(.failure(NSError(domain: "AuthAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Logout
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL + "/auth/logout"
        print("[AuthAPI][LOGOUT] URL: \(url)")
        KeychainService.shared.delete("accessToken")
        AF.request(url, method: .post, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                print("[AuthAPI] LOGOUT response: \(String(describing: response.value))")
                switch response.result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        print("[AuthAPI][LOGOUT] Error: \(error)")
                        completion(.failure(error))
                }
            }
    }

}
