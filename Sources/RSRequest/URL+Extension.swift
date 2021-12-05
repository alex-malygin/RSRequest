//
//  URL+Extension.swift
//  RSRequest
//
//  Created by Alexander Malygin on 12/3/21.
//

import Foundation

extension URL {
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
