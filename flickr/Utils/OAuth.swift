//
//  OAuth.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/21/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation
import OAuthSwift

enum OAuthError: Error {
    case unknown
}

protocol OAuthable {
    func handle(url: URL)
    func doOAuth(completion: @escaping (Result<Void,Error>) -> Void)
    func logout()
    func post(to url: URL, with parameters:[String:String], completion: @escaping (Result<Void, Error>)->Void)
}

class OAuth: OAuthable {
    
    // MARK: - Variables
    
    // MARK: Private
    private var oauthswift: OAuth1Swift?
    
    // MARK: - Initization
    
    // MARK: - Functions
    
    // MARK: Public
    func handle(url: URL) {
         OAuthSwift.handle(url: url)
    }
    
    func doOAuth(completion: @escaping (Result<Void,Error>) -> Void) {
        self.oauthswift = OAuth1Swift(
            consumerKey:    FlickrSecrets.FlickrApiKey,
            consumerSecret: FlickrSecrets.FlickrApiSecret,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )
        
        self.oauthswift?.authorizeURLHandler = OAuthSwiftOpenURLExternally.sharedInstance
        
        let _ = self.oauthswift?.authorize(
        withCallbackURL: URL(string: "flickr-client://oauth-callback/flickr")!) { result in
            switch result {
            case .success(let (credential, _, _)):
                self.checkToken(with: credential, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func post(to url: URL, with parameters:[String:String], completion: @escaping (Result<Void, Error>)->Void) {
        _ = self.oauthswift?.client.post(url, parameters: parameters) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        self.oauthswift?.client.credential.oauthToken = ""
        self.oauthswift?.client.credential.oauthRefreshToken = ""
        self.oauthswift?.client.credential.oauthTokenSecret = ""
        self.oauthswift?.client.credential.oauthTokenExpiresAt = nil
        Environment.shared.signedInUser = nil
    }
    
    // MARK: Private
    private func checkToken(with crediential: OAuthSwiftCredential, completion: @escaping (Result<Void,Error>) -> Void) {
        var parameters = FlickrService.buildBaseDictionary(method: .checkToken, withApiKey: true)
        parameters["oauth_token"] = crediential.oauthToken

        _ = self.oauthswift?.client.post(FlickrService.apiBaseURL, parameters: parameters) { result in
            switch result {
            case .success(let resp):
                if let decodedJSON = try? JSONDecoder().decode(CheckTokenResponse.self, from: resp.data) {
                    Environment.shared.signedInUser = decodedJSON.oauth.user.toEntity()
                    completion(.success(()))
                } else {
                    completion(.failure(OAuthError.unknown))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
