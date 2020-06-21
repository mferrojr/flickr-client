//
//  PhotosCommentsResponse.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/20/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PhotoCommentsResponse {

    enum CodingKeys: String, CodingKey {
        case stat
    }
}

// MARK: - Decodable
extension PhotoCommentsResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
    }

}
