//
//  GetCommentsMetaInfoResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct GetCommentsMetaInfoResponse {
    var id: String
    var authorname: String
    var content: String

    enum CodingKeys: String, CodingKey {
        case id
        case authorname
        case _content
    }
}

// MARK: - Decodable
extension GetCommentsMetaInfoResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        authorname = try container.decode(String.self, forKey: .authorname)
        content = try container.decode(String.self, forKey: ._content)
    }

}

extension GetCommentsMetaInfoResponse {
    
    func toEntity() -> CommentEntity {
        return CommentEntity(
            id: self.id,
            authorname: self.authorname,
            content: self.content
        )
    }
}
