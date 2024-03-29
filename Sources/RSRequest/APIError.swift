//
//  APIError.swift
//  RSRequest
//
//  Created by Alexander Malygin on 12/3/21.
//

import Foundation

enum APIError: Error, LocalizedError {
    case unknown
    case apiError(reason: String)
    case parserError(reason: String)
    case networkError(from: URLError)
    case invalidServerResponse
    case invalidURL
    case urlRequestError
        

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        case .invalidServerResponse:
            return "Invalid Server Response"
        case .invalidURL:
            return "Invalid URL"
        case .urlRequestError:
            return "Error with url request"
        }
    }
}
