//
//  CheckTokenAuthResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/24/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct CheckTokenAuthResponse {
    var user: CheckTokenAuthUserResponse

    enum CodingKeys: String, CodingKey {
        case user
    }
}

// MARK: - Extensions

// MARK: Decodable
extension CheckTokenAuthResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        user = try container.decode(CheckTokenAuthUserResponse.self, forKey: .user)
    }

}
