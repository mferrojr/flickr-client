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
    func onSubmitCompleted(with comment: CommentEntity)
    func onSignInFailed()
    func onPhotoMetadataFetchCompleted(with data: PhotoDetailModel)
    func onPhotoMetadataFetchFailed(with reason: String)
}

struct PhotoDetailModel {
    var numOfComments: Int
    var numOfFavorites: Int
    var description: String
    var comments: [CommentEntity]
}

class PhotoDetailViewModel {

    // MARK: - Variables

    // MARK: Public
    weak var delegate: PhotoDetailViewModelDelegate?
    
    // MARK: Private
    private var flickrService: FlickrServicable
    private var oauthable: OAuthable
    private let queue = OperationQueue()
    private var photoInfoContext: PhotoInfoContext
    private var getCommentsContext: GetCommentsContext
    private var getFavortiesContext: GetFavoriteContext

    // MARK: - Initialization
    init(flickrServicable: FlickrServicable, oauthable: OAuthable) {
        self.flickrService = flickrServicable
        self.oauthable = oauthable
        self.photoInfoContext = PhotoInfoContext()
        self.getCommentsContext = GetCommentsContext()
        self.getFavortiesContext = GetFavoriteContext()
        self.queue.qualityOfService = .userInitiated
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func fetchMetadata(for photo: PhotoEntity) {
        let photoInfoOp = self.fetchPhotoInfoOperation(by: photo)
        let getCommentsOp = self.fetchGetCommentsOperation(by: photo)
        let getFavsOp = self.fetchGetFavoritesOperation(by: photo)
        let completionOp = self.fetchCompletionBlock()
        completionOp.addDependency(photoInfoOp)
        completionOp.addDependency(getCommentsOp)
        completionOp.addDependency(getFavsOp)
        queue.addOperation(completionOp)
    }
    
    func add(by photoId: String, with comments: String) {
        let request = PhotoCommentsRequest(photoId: photoId, comments: comments)

        if Environment.shared.signedInUser != nil {
            self.handleAddingComment(with: request)
        } else {
            self.handleOAuth(with: request)
        }
    }
    
    func cancelFetchData() {
        self.queue.cancelAllOperations()
    }
    
    // MARK: Private
    private func fetchPhotoInfoOperation(by photo: PhotoEntity) -> Operation {
        let photoInfoOperation = PhotoInfoOperation(
            photoId: photo.id,
            flickrServicable: self.flickrService,
            context: self.photoInfoContext)
        photoInfoOperation.errorCallback = { [weak self] _ in
            self?.handleFlickrServiceError(with: self?.photoInfoContext.error )
        }
        queue.addOperation(photoInfoOperation)
        return photoInfoOperation
    }
    
    private func fetchGetCommentsOperation(by photo: PhotoEntity) -> Operation {
        let getCommentsOp = GetCommentsOperation(
            photoId: photo.id,
            flickrServicable: self.flickrService,
            context: self.getCommentsContext)
        getCommentsOp.errorCallback = { [weak self] _ in
            self?.handleFlickrServiceError(with: self?.getCommentsContext.error )
        }
        queue.addOperation(getCommentsOp)
        return getCommentsOp
    }
    
    private func fetchGetFavoritesOperation(by photo: PhotoEntity) -> Operation {
        let getFavoritesOp = GetFavoritesOperation(
            photoId: photo.id,
            flickrServicable: self.flickrService,
            context: self.getFavortiesContext)
        getFavoritesOp.errorCallback = { [weak self] _ in
            self?.handleFlickrServiceError(with: self?.getFavortiesContext.error )
        }
        queue.addOperation(getFavoritesOp)
        return getFavoritesOp
    }
    
    private func fetchCompletionBlock() -> Operation {
        let completionOperation = Operation()
        completionOperation.completionBlock = { [weak self] in
            if let error = self?.getFavortiesContext.error {
                self?.handleFlickrServiceError(with: error)
                return
            }
            
            if let error = self?.getCommentsContext.error {
                self?.handleFlickrServiceError(with: error)
                return
            }
            
            if let error = self?.photoInfoContext.error {
                self?.handleFlickrServiceError(with: error)
                return
            }
            
            DispatchQueue.main.async {
                let model = PhotoDetailModel(
                    numOfComments: self?.photoInfoContext.comments ?? 0,
                    numOfFavorites: self?.getFavortiesContext.total ?? 0,
                    description: self?.photoInfoContext.description ?? "",
                    comments: self?.getCommentsContext.comments ?? [])
                self?.delegate?.onPhotoMetadataFetchCompleted(with: model)
            }
        }
        
        return completionOperation
    }
    
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
                    self.delegate?.onSubmitCompleted(with:
                        CommentEntity(
                            id: Environment.shared.signedInUser?.id ?? "",
                            authorname: Environment.shared.signedInUser?.userName ?? "Me",
                            content: request.comments
                        )
                    )
                }
            }
        })
    }
    
    private func handleFlickrServiceError(with error: FlickrServiceError?) {
        guard let error = error else { return }
        DispatchQueue.main.async { [weak self] in
           switch error {
           case .cancelled:
               break
           default:
                self?.cancelFetchData()
                self?.delegate?.onPhotoMetadataFetchFailed(with: error.reason)
           }
        }
    }
    
}
