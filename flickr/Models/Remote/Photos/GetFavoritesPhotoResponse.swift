//
//  GetFavoritesPersonResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct GetFavoritesPhotoResponse {
    var id: String
    var total: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case total
    }
}

// MARK: - Decodable
extension GetFavoritesPhotoResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        total = try Int(container.decode(String.self, forKey: .total)) ?? 0
    }

}
