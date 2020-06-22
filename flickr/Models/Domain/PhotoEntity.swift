//
//  PhotoEntity.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/20/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PhotoEntity {
    var id: String
    var title: String
    var farm: Int
    var server: Int
    var secret: String

}

// MARK: - Extensions

extension PhotoEntity {
    
    var largePhotoUrl: URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")
    }
    
    var mediumPhotoUrl: URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")
    }
    
    var largeSquareUrl: URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")
    }
    
}
