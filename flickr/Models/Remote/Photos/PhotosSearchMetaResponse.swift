//
//  PhotosSearchMetaResponse.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct PhotosSearchMetaResponse {
    var page: Int
    var pages: Int
    var perpage: Int
    var total: Int
    var photos: [PhotoMetaResponse]

    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case total
        case photo
    }
}

// MARK: - Decodable
extension PhotosSearchMetaResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        pages = try container.decode(Int.self, forKey: .pages)
        perpage = try container.decode(Int.self, forKey: .perpage)
        total = try Int(container.decode(String.self, forKey: .total)) ?? 0

        do {
           photos = try container.decode([PhotoMetaResponse].self, forKey: .photo)
        } catch {
           photos = [PhotoMetaResponse]()
        }
    }

}
