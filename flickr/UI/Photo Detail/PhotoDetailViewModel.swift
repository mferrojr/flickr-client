//
//  PhotoDetailViewModel.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

protocol PhotoDetailViewModelDelegate: class {
    func onSubmitFailed(with: String)
    func onSubmitCompleted()
}

class PhotoDetailViewModel {

    // MARK: - Variables

    // MARK: Public
    weak var delegate: PhotoDetailViewModelDelegate?
    
    // MARK: Private
    private var flickrService: FlickrServicable
    private var dataTask: URLSessionDataTask?

    // MARK: - Initialization
    init(flickrServicable: FlickrServicable) {
        self.flickrService = flickrServicable
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func add(by photoId: String, with comments: String) {
        let request = PhotoCommentsRequest(photoId: photoId, comments: comments)
        
        self.dataTask = self.flickrService.addComment(with: request, completion: { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.onSubmitFailed(with: error.reason)
                }
            case .success:
                DispatchQueue.main.async {
                    self.delegate?.onSubmitCompleted()
                }
            }
        })
    }
    
    func cancelFetchData() {
    }
    
}
