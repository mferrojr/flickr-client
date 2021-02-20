//
//  FlickrService.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/20/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

enum FlickrServiceError: Error {
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

protocol FlickrServicable {
    func searchPhotos(with request: PhotoSearchRequest, page: Int, completion:@escaping (Result<PhotosSearchResponse, FlickrServiceError>)->Void) -> URLSessionDataTask?
    func getPeopleInfo(with request: PeopleInfoRequest, completion:@escaping (Result<PeopleInfoResponse?, FlickrServiceError>)->Void) -> URLSessionDataTask?
    func getPhotoInfo(with request: PhotoInfoRequest, completion:@escaping (Result<PhotoInfoResponse, FlickrServiceError>)->Void) -> URLSessionDataTask?
    func getFavorites(with request: GetFavoritesRequest, completion:@escaping (Result<GetFavoritesResponse, FlickrServiceError>)->Void) -> URLSessionDataTask?
    func getComments(with request: GetCommentsRequest, completion:@escaping (Result<GetCommentsResponse, FlickrServiceError>)->Void) -> URLSessionDataTask?
    func addComment(with request: PhotoCommentsRequest, completion:@escaping (Result<Void, FlickrServiceError>)->Void)
}

struct FlickrService: FlickrServicable {

    // MARK: - Variables
    
    // MARK: Public
    enum Method: String {
        case photosSearch = "flickr.photos.search"
        case addComment = "flickr.photos.comments.addComment"
        case peopleGetInfo = "flickr.people.getInfo"
        
        // https://www.flickr.com/services/api/explore/flickr.photos.getInfo
        case photosGetInfo = "flickr.photos.getInfo"
        // https://www.flickr.com/services/api/flickr.photos.comments.getList.html
        case commentsGetList = "flickr.photos.comments.getList"
        // https://www.flickr.com/services/api/flickr.photos.getFavorites.html
        case photosGetFavorites = "flickr.photos.getFavorites"
        // https://www.flickr.com/services/api/flickr.auth.oauth.checkToken.htm
        case checkToken = "flickr.auth.oauth.checkToken"
    }
    
    static let apiBaseURL = URL(string: "https://api.flickr.com/services/rest/")!
    
    // MARK: Private
    private var client: HTTPClientable
    private var oauth: OAuthable
    
    // MARK: - Initialization
    init(client: HTTPClientable, oauthable: OAuthable) {
        self.client = client
        self.oauth = oauthable
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func searchPhotos(with request: PhotoSearchRequest, page: Int, completion:@escaping (Result<PhotosSearchResponse, FlickrServiceError>)->Void) -> URLSessionDataTask? {
        var queryItems = self.buildBaseQueryItems(method: .photosSearch, withApiKey: true)
        queryItems.append(URLQueryItem(name: "tags", value: request.tag))
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        
        let request = HTTPRequest(
            method: .get,
            baseURL: FlickrService.apiBaseURL,
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
    
    func getPeopleInfo(with request: PeopleInfoRequest, completion:@escaping (Result<PeopleInfoResponse?, FlickrServiceError>)->Void) -> URLSessionDataTask? {
        var queryItems = self.buildBaseQueryItems(method: .peopleGetInfo, withApiKey: true)
        queryItems.append(URLQueryItem(name: "user_id", value: request.userId))
        
        let request = HTTPRequest(
            method: .get,
            baseURL: FlickrService.apiBaseURL,
            path: "",
            queryItems: queryItems
        )

        return self.client.perform(request) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 && response.body == nil {
                     completion(.success(nil))
                } else {
                    guard let resp = try? response.decode(to: PeopleInfoResponse.self) else {
                        completion(.failure(FlickrServiceError.invalidResponse))
                        return
                    }

                    completion(.success(resp.body))
                }
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
    
    func getPhotoInfo(with request: PhotoInfoRequest, completion:@escaping (Result<PhotoInfoResponse, FlickrServiceError>)->Void) -> URLSessionDataTask? {
        var queryItems = self.buildBaseQueryItems(method: .photosGetInfo, withApiKey: true)
        queryItems.append(URLQueryItem(name: "photo_id", value: request.photoId))
        
        let request = HTTPRequest(
            method: .get,
            baseURL: Self.apiBaseURL,
            path: "",
            queryItems: queryItems
        )

        return self.client.perform(request) { result in
            switch result {
            case .success(let response):
                guard let response = try? response.decode(to: PhotoInfoResponse.self) else {
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
    
    func getFavorites(with request: GetFavoritesRequest, completion:@escaping (Result<GetFavoritesResponse, FlickrServiceError>)->Void) -> URLSessionDataTask? {
        var queryItems = self.buildBaseQueryItems(method: .photosGetFavorites, withApiKey: true)
        queryItems.append(URLQueryItem(name: "photo_id", value: request.photoId))
        
        let request = HTTPRequest(
            method: .get,
            baseURL: Self.apiBaseURL,
            path: "",
            queryItems: queryItems
        )

        return self.client.perform(request) { result in
            switch result {
            case .success(let response):
                guard let response = try? response.decode(to: GetFavoritesResponse.self) else {
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
    
    func getComments(with request: GetCommentsRequest, completion: @escaping (Result<GetCommentsResponse, FlickrServiceError>) -> Void) -> URLSessionDataTask? {
        var queryItems = self.buildBaseQueryItems(method: .commentsGetList, withApiKey: true)
        queryItems.append(URLQueryItem(name: "photo_id", value: request.photoId))
        
        let request = HTTPRequest(
            method: .get,
            baseURL: Self.apiBaseURL,
            path: "",
            queryItems: queryItems
        )

        return self.client.perform(request) { result in
            switch result {
            case .success(let response):
                guard let response = try? response.decode(to: GetCommentsResponse.self) else {
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
        var parameters = Self.buildBaseDictionary(method: .addComment)
        parameters["photo_id"] = request.photoId
        parameters["comment_text"] = request.comments
        
        self.oauth.post(to: FlickrService.apiBaseURL, with: parameters, completion: { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure:
               completion(.failure(FlickrServiceError.network))
            }
        })
    }
    
    static func buildBaseDictionary(method: FlickrService.Method, withApiKey: Bool = false) -> [String:String] {
        var dict = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1"
        ]
        
        if withApiKey {
            dict["api_key"] =  FlickrSecrets.FlickrApiKey
        }
        return dict
    }
    
}

// MARK: - Private Functions
private extension FlickrService {
    
    func buildBaseQueryItems(method: FlickrService.Method, withApiKey: Bool = false) -> [URLQueryItem] {
        return Self.buildBaseDictionary(method: method, withApiKey: withApiKey).map{ URLQueryItem(name: $0, value: $1) }
    }
    
}
