//
//  PhotoMetaResponse.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PhotoMetaResponse {
    var id: String
    var title: String
    var farm: Int
    var server: Int
    var secret: String
    var owner: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case farm
        case server
        case secret
        case owner
    }
}

// MARK: - Extensions

// MARK: Decodable
extension PhotoMetaResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        farm = try container.decode(Int.self, forKey: .farm)
        server = try Int(container.decode(String.self, forKey: .server)) ?? 0
        secret = try container.decode(String.self, forKey: .secret)
        owner = try container.decode(String.self, forKey: .owner)
    }

}

// MARK: Mappings
extension PhotoMetaResponse {
    
    func toEntity() -> PhotoEntity {
        return PhotoEntity(
            id: id,
            title: title,
            farm: farm,
            server: server,
            secret: secret,
            owner: owner
        )
    }
}
