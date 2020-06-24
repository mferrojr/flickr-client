//
//  PhotoCollectionViewModel.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

protocol PhotoCollectionViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
    func onSignOutCompleted()
    func onSignInCompleted()
    func onSignInFailed()
}

struct PhotoCollectionModel {
    var photo: PhotoEntity
    var person: PersonEntity?
}

class PhotoCollectionViewModel {

    // MARK: - Variables

    // MARK: Public
    weak var delegate: PhotoCollectionViewModelDelegate?
    
    var totalCount: Int {
        return total
    }
    
    // MARK: Private
    private var isFetchInProgress: Bool
    private var currentPage: Int
    private var total: Int
    private var flickrService: FlickrServicable
    private var oauthable: OAuthable
    private var people: [PeopleInfoContext]
    private var data: [PhotoCollectionModel]
    private var searchContext: SearchPhotosContext
    private let queue = OperationQueue()

    // MARK: - Initialization
    init(flickrServicable: FlickrServicable, oauthable: OAuthable) {
        self.isFetchInProgress = false
        self.currentPage = 1
        self.total = 0
        self.flickrService = flickrServicable
        self.oauthable = oauthable
        self.people = [PeopleInfoContext]()
        self.data = [PhotoCollectionModel]()
        self.searchContext = SearchPhotosContext()
        self.queue.qualityOfService = .userInitiated
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= data.count
    }
    
    func entity(at index: Int) -> PhotoCollectionModel {
       return data[index]
    }
    
    func fetchPhotos(by tag: String) {
        guard !self.isFetchInProgress else { return }

        self.isFetchInProgress = true
        
        // Search Photos
        let searchPhotosOperation = self.searchPhotosOperation(by: tag)
        
        let photosReceivedOperation = BlockOperation { [weak self] in
            guard let updateUIOperation = self?.fetchCompletionBlock() else {
                self?.delegate?.onFetchFailed(with: "Error")
                return
            }
            
            self?.searchContext.photos.forEach {
                let context = PeopleInfoContext()
                self?.people.append(context)
                let personOp = PeopleInfoOperation(userId: $0.owner, flickrServicable: Services.flickrService, context: context)
                personOp.errorCallback = { [weak self] _ in
                    self?.handleFlickrServiceError(with: context.error )
                }
                updateUIOperation.addDependency(personOp)
                self?.queue.addOperation(personOp)
            }
            
            self?.queue.addOperation(updateUIOperation)
        }
        
        photosReceivedOperation.addDependency(searchPhotosOperation)
        queue.addOperation(photosReceivedOperation)
    }
    
    func reset() {
        self.data.removeAll()
        self.total = 0
        self.currentPage = 1
        self.cancelFetchData()
    }
    
    func cancelFetchData() {
        self.queue.cancelAllOperations()
        self.isFetchInProgress = false
    }
    
    func signInOrOut() {
        if Environment.shared.signedInUser != nil {
            self.oauthable.logout()
            self.delegate?.onSignOutCompleted()
        } else {
            self.oauthable.doOAuth { result in
                switch result {
                case .success:
                    self.delegate?.onSignInCompleted()
                case .failure:
                    self.delegate?.onSignInFailed()
                }
            }
        }
    }
    
    // MARK: Private
    private func calculateIndexPathsToReload(from newPhotos: [PhotoCollectionModel]?) -> [IndexPath]? {
        guard let newPhotos = newPhotos else { return nil }
        
        let startIndex = self.data.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    private func searchPhotosOperation(by tag: String) -> Operation {
        self.searchContext = SearchPhotosContext()
        let searchPhotosOperation = SearchPhotosOperation(
            flickrServicable: self.flickrService,
            page: self.currentPage,
            tag: tag,
            context: searchContext)
        searchPhotosOperation.errorCallback = { [weak self] _ in
            self?.handleFlickrServiceError(with: self?.searchContext.error )
        }
        queue.addOperation(searchPhotosOperation)
        return searchPhotosOperation
    }
    
    private func fetchCompletionBlock() -> Operation {
        let completionOperation = Operation()
        completionOperation.completionBlock = { [weak self] in
            if let error = self?.searchContext.error {
                self?.handleFlickrServiceError(with: error)
            } else {
                DispatchQueue.main.async {
                    self?.currentPage += 1
                    self?.isFetchInProgress = false
                    self?.total = self?.searchContext.total ?? 0

                    if let photos = self?.searchContext.photos {
                        var newData = [PhotoCollectionModel]()
                            
                        for photo in photos {
                            var person: PersonEntity?
                            if let personContext = self?.people.first(where: { $0.userId == photo.owner }) {
                                person = PersonEntity(id: personContext.userId, userName: personContext.userName)
                            }
                            
                            newData.append(
                                PhotoCollectionModel(
                                    photo: photo,
                                    person: person
                                )
                            )
                        }
                        self?.data.append(contentsOf: newData)
                    }
                       
                    if (self?.searchContext.page ?? 0) > 1 {
                        let indexPathsToReload = self?.calculateIndexPathsToReload(from: self?.data)
                        self?.delegate?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self?.delegate?.onFetchCompleted(with: .none)
                    }
                }
           }
        }
        
        return completionOperation
    }
    
    private func handleFlickrServiceError(with error: FlickrServiceError?) {
        guard let error = error else { return }
        DispatchQueue.main.async { [weak self] in
           switch error {
           case .cancelled:
               break
           default:
               self?.cancelFetchData()
               self?.delegate?.onFetchFailed(with: error.reason)
           }
        }
    }
    
}
