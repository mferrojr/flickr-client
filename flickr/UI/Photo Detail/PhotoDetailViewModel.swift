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
    func onSignInFailed()
}

class PhotoDetailViewModel {

    // MARK: - Variables

    // MARK: Public
    weak var delegate: PhotoDetailViewModelDelegate?
    
    // MARK: Private
    private var flickrService: FlickrServicable
    private var oauthable: OAuthable

    // MARK: - Initialization
   init(flickrServicable: FlickrServicable, oauthable: OAuthable) {
        self.flickrService = flickrServicable
        self.oauthable = oauthable
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func add(by photoId: String, with comments: String) {
        let request = PhotoCommentsRequest(photoId: photoId, comments: comments)

        if Environment.shared.isSignedIn {
            self.handleAddingComment(with: request)
        } else {
            self.handleOAuth(with: request)
        }
    }
    
    // MARK: Private
    private func handleOAuth(with request: PhotoCommentsRequest) {
        self.oauthable.doOAuth { [weak self] result in
            switch result {
            case .success:
               self?.handleAddingComment(with: request)
            case .failure:
               self?.delegate?.onSignInFailed()
            }
        }
    }
    
    private func handleAddingComment(with request: PhotoCommentsRequest) {
        self.flickrService.addComment(with: request, completion: { result in
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
    
}
