//
//  Headers.swift
//  RSRequest
//
//  Created by Alexander Malygin on 12/3/21.
//

import Foundation

public struct HTTPHeaders {
    private var headers: [HTTPHeader] = []

    public init() {}

    public init(_ headers: [HTTPHeader]) {
        self.init()

        headers.forEach { update($0) }
    }

    public init(_ dictionary: [String: String]) {
        self.init()

        dictionary.forEach { update(HTTPHeader(name: $0.key, value: $0.value)) }
    }

    public mutating func add(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }

    public mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    public mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }

        headers.replaceSubrange(index...index, with: [header])
    }

    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }

        headers.remove(at: index)
    }

    public mutating func sort() {
        headers.sort { $0.name.lowercased() < $1.name.lowercased() }
    }

    public func sorted() -> HTTPHeaders {
        var headers = self
        headers.sort()

        return headers
    }

    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }

        return headers[index].value
    }

    public subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }

    public var dictionary: [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }

        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()

        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(elements)
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}

extension HTTPHeaders: Collection {
    public var startIndex: Int {
        headers.startIndex
    }

    public var endIndex: Int {
        headers.endIndex
    }

    public subscript(position: Int) -> HTTPHeader {
        headers[position]
    }

    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        headers.map { $0.description }
            .joined(separator: "\n")
    }
}

// MARK: - HTTPHeader

/// A representation of a single HTTP header's name / value pair.
public struct HTTPHeader: Hashable {
    /// Name of the header.
    public let name: String

    /// Value of the header.
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeader: CustomStringConvertible {
    public var description: String {
        "\(name): \(value)"
    }
}

extension HTTPHeader {
    public static func accept(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept", value: value)
    }

    public static func acceptCharset(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Charset", value: value)
    }

    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Language", value: value)
    }

    public static func acceptEncoding(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Encoding", value: value)
    }

    public static func authorization(username: String, password: String) -> HTTPHeader {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()

        return authorization("Basic \(credential)")
    }

    public static func authorization(bearerToken: String) -> HTTPHeader {
        authorization("Bearer \(bearerToken)")
    }

    public static func authorization(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: value)
    }

    public static func contentDisposition(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Disposition", value: value)
    }

    public static func contentType(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Type", value: value)
    }

    public static func userAgent(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "User-Agent", value: value)
    }
}

extension Array where Element == HTTPHeader {
    /// Case-insensitively finds the index of an `HTTPHeader` with the provided name, if it exists.
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

// MARK: - Defaults

extension HTTPHeaders {
    /// The default set of `HTTPHeaders` used by Alamofire. Includes `Accept-Encoding`, `Accept-Language`, and
    /// `User-Agent`.
    public static let `default`: HTTPHeaders = [.defaultAcceptEncoding,
                                                .defaultAcceptLanguage,
                                                .defaultUserAgent]
}

extension HTTPHeader {
    public static let defaultAcceptEncoding: HTTPHeader = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br", "gzip", "deflate"]
        } else {
            encodings = ["gzip", "deflate"]
        }

        return .acceptEncoding(encodings.qualityEncoded())
    }()

    public static let defaultAcceptLanguage: HTTPHeader = {
        .acceptLanguage(Locale.preferredLanguages.prefix(6).qualityEncoded())
    }()

    public static let defaultUserAgent: HTTPHeader = {
        let info = Bundle.main.infoDictionary
        let executable = (info?[kCFBundleExecutableKey as String] as? String) ??
            (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
            "Unknown"
        let bundle = info?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"

        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            let osName: String = {
                #if os(iOS)
                #if targetEnvironment(macCatalyst)
                return "macOS(Catalyst)"
                #else
                return "iOS"
                #endif
                #elseif os(watchOS)
                return "watchOS"
                #elseif os(tvOS)
                return "tvOS"
                #elseif os(macOS)
                return "macOS"
                #elseif os(Linux)
                return "Linux"
                #elseif os(Windows)
                return "Windows"
                #else
                return "Unknown"
                #endif
            }()

            return "\(osName) \(versionString)"
        }()

        let userAgent = "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"

        return .userAgent(userAgent)
    }()
}

extension Collection where Element == String {
    func qualityEncoded() -> String {
        enumerated().map { index, encoding in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}

// MARK: - System Type Extensions

extension URLRequest {
    /// Returns `allHTTPHeaderFields` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        get { allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { allHTTPHeaderFields = newValue.dictionary }
    }
}

extension HTTPURLResponse {
    /// Returns `allHeaderFields` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        (allHeaderFields as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()
    }
}

extension URLSessionConfiguration {
    /// Returns `httpAdditionalHeaders` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        get { (httpAdditionalHeaders as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { httpAdditionalHeaders = newValue.dictionary }
    }
}
