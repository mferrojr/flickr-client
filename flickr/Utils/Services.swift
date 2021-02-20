//
//  Services.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/20/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

class Services {
    
    static let httpClient: HTTPClientable = HTTPClient()
    static let oauth: OAuthable = OAuth()
    static let flickrService: FlickrServicable = FlickrService(client: httpClient, oauthable: oauth)
    
}
