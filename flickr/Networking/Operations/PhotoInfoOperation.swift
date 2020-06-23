//
//  PhotoInfoOperation.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

class PhotoInfoContext {
    var photoId = ""
    var comments = 0
    var description = ""
    var error: FlickrServiceError?
}

class PhotoInfoOperation: BaseOperation {
    
    //MARK: - Variables
    
    //MARK: Private
    private var photoId: String
    private var flickrServicable: FlickrServicable
    private var context: PhotoInfoContext

    required init(photoId: String, flickrServicable: FlickrServicable, context: PhotoInfoContext) {
        self.photoId = photoId
        self.flickrServicable = flickrServicable
        self.context = context
    }

    override func main() {
       super.main()
       self.getPhotoInfo()
    }

    //MARK: - Functions

    //MARK: Private
    private func getPhotoInfo(){
        let request = PhotoInfoRequest(photoId: self.photoId)

        self.dataTask = self.flickrServicable.getPhotoInfo(with: request) { result in
            switch result {
            case .success(let data):
                self.context.comments = data.photoInfoMeta.commentsMeta.content
                self.context.description = data.photoInfoMeta.descriptionMeta.content
                self.context.photoId = data.photoInfoMeta.id
                self.done()
            case .failure(let error):
                self.context.error = error
                self.errorCB(error)
            }
        }
    }
}
