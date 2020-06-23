//
//  PhotoInfoResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PhotoInfoResponse {
    var photoInfoMeta: PhotoInfoMetaResponse
    
    enum CodingKeys: String, CodingKey {
        case photo
    }
}

// MARK: - Decodable
extension PhotoInfoResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        photoInfoMeta = try container.decode(PhotoInfoMetaResponse.self, forKey: .photo)
    }

}
