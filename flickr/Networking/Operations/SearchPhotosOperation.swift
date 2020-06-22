//
//  SearchPhotosOperation.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/22/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

class SearchPhotosContext {
    var page: Int = 0
    var pages: Int = 0
    var perpage: Int = 0
    var total: Int = 0
    var photos = [PhotoEntity]()
    var error: FlickrServiceError?
}

class SearchPhotosOperation: BaseOperation {
    
    //MARK: - Variables
    
    //MARK: Public
    private var flickrServicable: FlickrServicable
    private var page: Int
    private var tag: String
    private var context: SearchPhotosContext
    
    required init(flickrServicable: FlickrServicable, page: Int, tag: String, context: SearchPhotosContext) {
        self.flickrServicable = flickrServicable
        self.page = page
        self.tag = tag
        self.context = context
    }
    
    override func main() {
        super.main()
        self.getUserInfo()
    }
    
    //MARK: - Functions
    
    //MARK: Private
    private func getUserInfo(){
        let request = PhotoSearchRequest(tag: self.tag)
        
        self.dataTask = self.flickrServicable.searchPhotos(with: request, page: self.page) { result in
            switch result {
            case .success(let data):
                self.context.page = data.photosMeta.page
                self.context.pages = data.photosMeta.pages
                self.context.perpage = data.photosMeta.perpage
                self.context.total = data.photosMeta.total
                self.context.photos = data.photosMeta.photos.map { $0.toEntity() }
                self.done()
            case .failure(let error):
                self.context.error = error
                self.errorCB(error)
            }
        }
    }
    
}
