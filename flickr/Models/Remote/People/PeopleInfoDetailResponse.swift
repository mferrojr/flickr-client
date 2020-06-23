//
//  PeopleInfoDetailResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/22/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PeopleInfoDetailResponse {
    var id: String
    var username: PeopleInfoDetailUserNameResponse

    enum CodingKeys: String, CodingKey {
        case id
        case username
    }
}

// MARK: - Extensions

// MARK: Decodable
extension PeopleInfoDetailResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            id = try container.decode(String.self, forKey: .id)
            username = try container.decode(PeopleInfoDetailUserNameResponse.self, forKey: .username)
        } catch  {
            throw error
        }
    }

}
