//
//  PhotoInfoMetaResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation


struct PhotoInfoMetaResponse {
    var id: String
    var commentsMeta: PhotoInfoMetaCommentResponse
    var descriptionMeta: PhotoInfoMetaDescriptionResponse

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case comments
    }
}

// MARK: - Decodable
extension PhotoInfoMetaResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        commentsMeta = try container.decode(PhotoInfoMetaCommentResponse.self, forKey: .comments)
        descriptionMeta = try container.decode(PhotoInfoMetaDescriptionResponse.self, forKey: .description)
    }

}

