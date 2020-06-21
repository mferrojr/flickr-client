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
    case cancelled
    
    var reason: String {
        switch self {
        case .invalidResponse:
            return "Unexpected response format"
        case .network:
            return "An error occuring retriving data"
        case .cancelled:
            return "Request cancelled"
        }
    }
}

enum FlickrServiceMethod: String {
    case photosSearch = "flickr.photos.search"
    case addComment = "flickr.photos.comments.addComment"
}

protocol FlickrServicable {
    func searchPhotos(with request: PhotoSearchRequest, page: Int, completion:@escaping (Result<PhotosSearchResponse, FlickrServiceError>)->Void) -> URLSessionDataTask?
    func addComment(with request: PhotoCommentsRequest, completion:@escaping (Result<Void, FlickrServiceError>)->Void)
}

final class FlickrService: FlickrServicable {

    // MARK: - Variables
    
    // MARK: Private
    private var client: HTTPClientable
    private var oauth: OAuthable

    private let apiBaseURL = URL(string: "https://api.flickr.com/services/rest/")!
    
    // MARK: - Initialization
    init(client: HTTPClientable, oauthable: OAuthable) {
        self.client = client
        self.oauth = oauthable
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func searchPhotos(with request: PhotoSearchRequest, page: Int, completion:@escaping (Result<PhotosSearchResponse, FlickrServiceError>)->Void) -> URLSessionDataTask? {
        var queryItems = self.buildBaseQueryItems(method: .photosSearch)
        queryItems.append(URLQueryItem(name: "tags", value: request.tag))
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "api_key", value: FlickrSecrets.FlickrApiKey))
        
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
            case .failure(let error):
                switch error {
                case .cancelled:
                    completion(.failure(FlickrServiceError.cancelled))
                default:
                    completion(.failure(FlickrServiceError.network))
                }
            }
        }
    }
    
    func addComment(with request: PhotoCommentsRequest, completion:@escaping (Result<Void, FlickrServiceError>)->Void) {
        var parameters = self.buildBaseDictionary(method: .addComment)
        parameters["photo_id"] = request.photoId
        parameters["comment_text"] = request.comments
        
        self.oauth.post(to: self.apiBaseURL, with: parameters, completion: { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure:
               completion(.failure(FlickrServiceError.network))
            }
        })
    }
    
    // MARK: Private
    private func buildBaseDictionary(method: FlickrServiceMethod) -> [String:String] {
        return [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1"
        ]
    }
    
    private func buildBaseQueryItems(method: FlickrServiceMethod) -> [URLQueryItem] {
        return self.buildBaseDictionary(method: method).map{ URLQueryItem(name: $0, value: $1) }
    }

}
