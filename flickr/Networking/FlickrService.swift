//
//  FlickrService.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/20/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

enum FlickrServiceError : Error {
    case invalidResponse
    case network
    
    var reason: String {
        switch self {
        case .invalidResponse:
            return "Unexpected response format"
        case .network:
            return "An error occuring retriving data"
        }
    }
}

enum FlickrServiceMethod: String {
    case photosSearch = "flickr.photos.search"
    case addComment = "flickr.photos.comments.addComment"
}

protocol FlickrServicable {
    func searchPhotos(with request: PhotoSearchRequest, page: Int, completion:@escaping (Result<PhotosSearchResponse, FlickrServiceError>)->Void) -> URLSessionDataTask?
    func addComment(with request: PhotoCommentsRequest, completion:@escaping (Result<PhotoCommentsResponse, FlickrServiceError>)->Void) -> URLSessionDataTask?
}

final class FlickrService: FlickrServicable {

    // MARK: - Variables
    
    // MARK: Private
    private var client: HTTPClientable

    // https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=a6ef5dcbcaf68383e4bda344ed3fb667&format=json&nojsoncallback=1&auth_token=72157714791251361-7ae13992a6301640&api_sig=c85c9b1ef477c92e6025716fdac7610e
    private let apiBaseURL = URL(string: "https://www.flickr.com/services/rest/?format=json&nojsoncallback=1")!
    
    // MARK: - Initialization
    init(client: HTTPClientable) {
        self.client = client
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func searchPhotos(with request: PhotoSearchRequest, page: Int, completion:@escaping (Result<PhotosSearchResponse, FlickrServiceError>)->Void) -> URLSessionDataTask? {
        
        var queryItems = self.buildBaseQueryItems(method: .photosSearch)
        queryItems.append(URLQueryItem(name: "tags", value: request.tag))
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        
        if false {
        } else {
            queryItems.append(URLQueryItem(name: "api_key", value: FlickrSecrets.FlickrApiKey))
        }
        
        let request = HTTPRequest(
            method: .get,
            baseURL: apiBaseURL,
            path: "",
            queryItems: queryItems
        )

        return self.client.perform(request) { result in
            switch result {
            case .success(let response):
                guard let response = try? response.decode(to: PhotosSearchResponse.self) else {
                    completion(.failure(FlickrServiceError.invalidResponse))
                    return
                }
                
                completion(.success(response.body))
            case .failure:
                completion(.failure(FlickrServiceError.network))
            }
        }
    }
    
    func addComment(with request: PhotoCommentsRequest, completion:@escaping (Result<PhotoCommentsResponse, FlickrServiceError>)->Void) -> URLSessionDataTask? {
        let request = HTTPRequest(
            method: .get,
            baseURL: apiBaseURL,
            path: "",
            queryItems: [
                URLQueryItem(name: "method", value: "flickr.photos.comments.addComment"),
                URLQueryItem(name: "photo_id", value: request.photoId),
                URLQueryItem(name: "comment_text", value: request.comments),
                URLQueryItem(name: "api_key", value: "")
            ]
        )

        return self.client.perform(request) { result in
            switch result {
            case .success(let response):
                guard let response = try? response.decode(to: PhotoCommentsResponse.self) else {
                    completion(.failure(FlickrServiceError.invalidResponse))
                    return
                }
                
                completion(.success(response.body))
            case .failure:
                completion(.failure(FlickrServiceError.network))
            }
        }
    }
    
    private func buildBaseQueryItems(method: FlickrServiceMethod) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "method", value: method.rawValue),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
    }

}
