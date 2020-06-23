//
//  PhotoInfoMetaDescriptionResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PhotoInfoMetaDescriptionResponse {
    var content: String

    enum CodingKeys: String, CodingKey {
        case _content
    }
}

// MARK: - Extensions

// MARK: Decodable
extension PhotoInfoMetaDescriptionResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        content = try container.decode(String.self, forKey: ._content)
    }

}

