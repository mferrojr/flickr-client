//
//  CheckTokenResponse.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/24/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct CheckTokenResponse {
    var oauth: CheckTokenAuthResponse

    enum CodingKeys: String, CodingKey {
        case oauth
    }
}

// MARK: - Extensions

// MARK: Decodable
extension CheckTokenResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        oauth = try container.decode(CheckTokenAuthResponse.self, forKey: .oauth)
    }

}
