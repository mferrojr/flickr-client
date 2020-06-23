//
//  GetCommentsResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct GetCommentsResponse {
    var comments: GetCommentsMetaResponse

    enum CodingKeys: String, CodingKey {
        case comments
    }
}

// MARK: - Decodable
extension GetCommentsResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        comments = try container.decode(GetCommentsMetaResponse.self, forKey: .comments)
    }

}
