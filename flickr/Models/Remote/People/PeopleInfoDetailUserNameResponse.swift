//
//  PeopleInfoDetailUserNameResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/22/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PeopleInfoDetailUserNameResponse {
    var content: String

    enum CodingKeys: String, CodingKey {
        case _content
    }
    
}

// MARK: - Extensions

// MARK: Decodable
extension PeopleInfoDetailUserNameResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        content = try container.decode(String.self, forKey: ._content)
    }

}
