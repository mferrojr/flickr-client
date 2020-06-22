//
//  HTTPRequest.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

struct HTTPHeader {
    let field: String
    let value: String
}

struct HTTPRequest {

    // MARK: - Variables
    
    // MARK: Public
    let baseURL: URL
    let path: String
    var queryItems: [URLQueryItem]?
    let method: HTTPMethod
    var headers: [HTTPHeader]?
    var body: Data?
    
    var requestURL: URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.baseURL.scheme
        urlComponents.host = self.baseURL.host
        urlComponents.path = self.baseURL.path
        urlComponents.queryItems = self.queryItems
        
        let url = urlComponents.url!.appendingPathComponent(self.path)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.httpBody = self.body

        self.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        
        return urlRequest
    }
}

extension HTTPRequest {
    
    init(method: HTTPMethod, baseURL: URL, path: String = "", queryItems: [URLQueryItem]? = nil) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
    }

    init<Body: Encodable>(method: HTTPMethod, baseURL: URL, path: String = "", body: Body) throws {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.body = try JSONEncoder().encode(body)
    }

}
