//
//  APIError.swift
//  RSRequest
//
//  Created by Alexander Malygin on 12/3/21.
//

import Foundation

public enum APIError: Error {
    
    case invalidURL
    case httpCode(Int)
    case unexpectedResponse
    case custom(String)
    case decodable(Decodable)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Не удалось собрать Адрес"
        case .httpCode(let code):   return "Не ожидаемый HTTP код: \(code)"
        case .unexpectedResponse:   return "Не ожидаемый ответ от сервера"
        case .custom(let message):  return message
        case .decodable:               return "Не ожидаемый ответ"
        }
    }
    
    public var decodable: Decodable? {
        switch self {
        case .decodable(let decodable):
            return decodable
        default:
            return nil
        }
    }
}
