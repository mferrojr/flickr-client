//
//  PhotoDetailViewModel.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

protocol PhotoDetailViewModelDelegate: class {
}

class PhotoDetailViewModel {

    // MARK: - Variables

    // MARK: Public
    weak var delegate: PhotoDetailViewModelDelegate?

    // MARK: - Initialization
    init() {
    }
    
    // MARK: - Functions
    
    // MARK: Public
    
    
    func cancelFetchData() {
    }
    
}
