//
//  AuthModels.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import Foundation

enum SuccessValue: Codable, Equatable {
    case int(Int)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else {
            throw DecodingError.typeMismatch(SuccessValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or Bool for success field"))
        }
    }

    // Encode accessToken
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let intValue):
            try container.encode(intValue)
        case .bool(let boolValue):
            try container.encode(boolValue)
        }
    }

    static func == (lhs: SuccessValue, rhs: SuccessValue) -> Bool {
        switch (lhs, rhs) {
        case let (.int(a), .int(b)):
            return a == b
        case let (.bool(a), .bool(b)):
            return a == b
        default:
            return false
        }
    }
}

struct LoginResponse: Codable {
    let data: LoginData
    let success: SuccessValue?
}

struct LoginData: Codable {
    let token: String
}

struct APIErrorResponse: Codable {
    let success: Bool
    let message: String?
}

