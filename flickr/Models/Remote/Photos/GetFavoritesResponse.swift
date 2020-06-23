//
//  GetFavoritesResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct GetFavoritesResponse {
    var photo: GetFavoritesPhotoResponse

    enum CodingKeys: String, CodingKey {
        case photo
    }
}

// MARK: - Decodable
extension GetFavoritesResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        photo = try container.decode(GetFavoritesPhotoResponse.self, forKey: .photo)
    }

}


