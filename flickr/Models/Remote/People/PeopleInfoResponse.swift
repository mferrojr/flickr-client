//
//  PeopleInfoResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/22/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PeopleInfoResponse {
    var person: PeopleInfoDetailResponse

    enum CodingKeys: String, CodingKey {
        case person
    }
}

// MARK: - Extensions

// MARK: Decodable
extension PeopleInfoResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
           person = try container.decode(PeopleInfoDetailResponse.self, forKey: .person)
        } catch  {
           throw error
        }
    }

}
