//
//  GetCommentsMetaResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct GetCommentsMetaResponse {
    var photoId: String
    var comments: [GetCommentsMetaInfoResponse]

    enum CodingKeys: String, CodingKey {
        case photo_id
        case comment
    }
}

// MARK: - Decodable
extension GetCommentsMetaResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        photoId = try container.decode(String.self, forKey: .photo_id)
        do {
            comments = try container.decode([GetCommentsMetaInfoResponse].self, forKey: .comment)
        } catch {
            comments = [GetCommentsMetaInfoResponse]()
        }
        
    }

}
