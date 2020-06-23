//
//  GetCommentsOperation.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

class GetCommentsContext {
    var photoId = ""
    var comments = [CommentEntity]()
    var error: FlickrServiceError?
}

class GetCommentsOperation: BaseOperation {
    
    //MARK: - Variables
    
    //MARK: Private
    private var photoId: String
    private var flickrServicable: FlickrServicable
    private var context: GetCommentsContext

    required init(photoId: String, flickrServicable: FlickrServicable, context: GetCommentsContext) {
        self.photoId = photoId
        self.flickrServicable = flickrServicable
        self.context = context
    }

    override func main() {
       super.main()
       self.getGetComments()
    }

    //MARK: - Functions

    //MARK: Private
    private func getGetComments(){
        let request = GetCommentsRequest(photoId: self.photoId)

        self.dataTask = self.flickrServicable.getComments(with: request) { result in
            switch result {
            case .success(let data):
                self.context.photoId = data.comments.photoId
                self.context.comments = data.comments.comments.map { $0.toEntity() }
                self.done()
            case .failure(let error):
                self.context.error = error
                self.errorCB(error)
            }
        }
    }
}
