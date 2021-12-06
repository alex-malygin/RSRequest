//
//  Session.swift
//  RSRequest
//
//  Created by Alexander Malygin on 12/4/21.
//

import Foundation
import Combine

// For make request
public let RSRequest = Session.default

public protocol RSRequestProtocol {
    func makeRequest<T: Codable>(endpoint: Endpoint) -> AnyPublisher<T, Error>
}

open class Session: RSRequestProtocol {
    
    public static let `default` = Session()
    
    public func makeRequest<T>(endpoint: Endpoint) -> AnyPublisher<T, Error> where T: Codable {
        do {
            let request = try endpoint.urlRequest()
            
            return URLSession.shared
                .dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    switch error {
                    case is URLError:
                        return APIError.apiError(reason: error.localizedDescription)
                    case is DecodingError:
                        return APIError.parserError(reason: error.localizedDescription)
                    default:
                        return APIError.unknown
                    }
                }
                .eraseToAnyPublisher()
            
        } catch let error {
            return Fail<T, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
}
