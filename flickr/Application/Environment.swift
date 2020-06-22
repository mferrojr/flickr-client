//
//  Environment.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/21/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

struct Environment {
    var isSignedIn:Bool
    static var shared = Environment(isSignedIn: false)
}
