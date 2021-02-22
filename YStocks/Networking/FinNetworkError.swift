/////
////  FinNetworkError.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation

enum FinNetworkError: Error {
    case responceSyntaxError(message: String)
    case serverError(code: Int)
    case unavailable
    case empty

    func message() -> String {
        switch self {
        case
            .responceSyntaxError(let message):
            return message
        case .serverError(let code):
            return "code \(code)"
        case .unavailable:
            return ""
        case .empty:
            return ""
        }
    }
}

extension FinNetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .responceSyntaxError:
            return NSLocalizedString("Responce syntax error", comment: "Network error")
        case .serverError:
            return NSLocalizedString("Server error", comment: "Network error")
        case .unavailable:
            return NSLocalizedString("Network unaviable", comment: "Network error")
        case .empty:
            return NSLocalizedString("Empty data", comment: "Network error")
        }
    }
}
