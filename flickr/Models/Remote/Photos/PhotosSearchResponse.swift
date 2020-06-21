//
//  PhotosSearchResponse.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PhotosSearchResponse {
    var photosMeta: PhotosSearchMetaResponse

    enum CodingKeys: String, CodingKey {
        case photos
    }
}

// MARK: - Decodable
extension PhotosSearchResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        photosMeta = try container.decode(PhotosSearchMetaResponse.self, forKey: .photos)
    }

}
