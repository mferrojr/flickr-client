//
//  GetFavoritesOperation.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

class GetFavoriteContext {
    var photoId = ""
    var total = 0
    var error: FlickrServiceError?
}

class GetFavoritesOperation: BaseOperation {
    
    //MARK: - Variables
    
    //MARK: Private
    private var photoId: String
    private var flickrServicable: FlickrServicable
    private var context: GetFavoriteContext

    required init(photoId: String, flickrServicable: FlickrServicable, context: GetFavoriteContext) {
        self.photoId = photoId
        self.flickrServicable = flickrServicable
        self.context = context
    }

    override func main() {
       super.main()
       self.getGetFavorites()
    }

    //MARK: - Functions

    //MARK: Private
    private func getGetFavorites(){
        let request = GetFavoritesRequest(photoId: self.photoId)

        self.dataTask = self.flickrServicable.getFavorites(with: request) { result in
            switch result {
            case .success(let data):
                self.context.photoId = data.photo.id
                self.context.total = data.photo.total
                self.done()
            case .failure(let error):
                self.context.error = error
                self.errorCB(error)
            }
        }
    }
}
