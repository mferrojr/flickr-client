//
//  CheckTokenAuthUserResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/24/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct CheckTokenAuthUserResponse {
    var id: String
    var username: String

    enum CodingKeys: String, CodingKey {
        case nsid
        case username
    }
}

// MARK: - Extensions

// MARK: Decodable
extension CheckTokenAuthUserResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .nsid)
        username = try container.decode(String.self, forKey: .username)
    }

}

extension CheckTokenAuthUserResponse {
    
    func toEntity() -> PersonEntity {
        return PersonEntity(id: self.id, userName: self.username)
    }
    
}

