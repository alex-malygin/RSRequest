//
//  Endpoint.swift
//  RSRequest
//
//  Created by Alexander Malygin on 12/4/21.
//

import Foundation

public typealias Parameters = [String: Any]

public enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public protocol Endpoint {
    var baseURL: String { get }
    var url: String { get }
    var method: HTTPMethodType { get }
    var query: [String: String]? { get }
    var params: Parameters? { get }
    var headers: HTTPHeaders { get }
}

public extension Endpoint {
    var baseURL: String {
        return ""
    }
}

//Default header
public extension Endpoint {
    var headers: HTTPHeaders {
        return HTTPHeaders([defaultHeader])
    }
}

//Make default URL Request
extension Endpoint {
    func urlRequest() throws -> URLRequest {
        
        var queryItems = [URLQueryItem]()
        if let query = query {
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        
        guard let url = URL(string: baseURL + url)?.appending(queryItems) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers.dictionary
        return request
    }
}

//Headers templates
public extension Endpoint {
    var defaultHeader: HTTPHeader {
        return HTTPHeader.contentType("application/json")
    }
}
