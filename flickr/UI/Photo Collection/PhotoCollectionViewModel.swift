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
    private var photos: [PhotoEntity]
    private var dataTask: URLSessionDataTask?

    // MARK: - Initialization
    init(flickrServicable: FlickrServicable) {
        self.isFetchInProgress = false
        self.currentPage = 1
        self.total = 0
        self.flickrService = flickrServicable
        self.photos = [PhotoEntity]()
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= photos.count
    }
    
    func entity(at index: Int) -> PhotoEntity {
       return photos[index]
    }
    
    func fetchPhotos(by tag: String) {
        guard !isFetchInProgress else { return }

        isFetchInProgress = true
        
        let request = PhotoSearchRequest(tag: tag)
        
        self.dataTask = self.flickrService.searchPhotos(with: request, page: self.currentPage, completion: { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    switch error {
                    case .cancelled:
                        break
                    default:
                        self.delegate?.onFetchFailed(with: error.reason)
                    }
                }
            case .success(let response):
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    self.total = response.photosMeta.total
                    let photos = response.photosMeta.photos.map({ $0.toEntity() })
                    self.photos.append(contentsOf: photos)
                    
                    if response.photosMeta.page > 1 {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: photos)
                        self.delegate?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.delegate?.onFetchCompleted(with: .none)
                    }
                }
            }
        })
    }
    
    func reset() {
        self.photos.removeAll()
        self.total = 0
        self.currentPage = 1
        self.cancelFetchData()
    }
    
    func cancelFetchData() {
        switch self.dataTask?.state {
        case .some(.running):
            self.dataTask?.cancel()
            self.dataTask = nil
        default:
            break
        }
       
    }
    
    // MARK: Private
    private func calculateIndexPathsToReload(from newPhotos: [PhotoEntity]) -> [IndexPath] {
        let startIndex = photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
}
