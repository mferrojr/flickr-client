//
//  PeopleInfoOperation.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/22/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

class PeopleInfoContext {
    var userId: String = ""
    var userName: String = ""
    var error: FlickrServiceError?
}

class PeopleInfoOperation: BaseOperation {
    
    //MARK: - Variables
    
    //MARK: Private
    private var userId: String
    private var flickrServicable: FlickrServicable
    private var context: PeopleInfoContext

    required init(userId: String, flickrServicable: FlickrServicable, context: PeopleInfoContext) {
        self.userId = userId
        self.flickrServicable = flickrServicable
        self.context = context
    }

    override func main() {
       super.main()
       self.getUserInfo()
    }

    //MARK: - Functions

    //MARK: Private
    private func getUserInfo(){
        let request = PeopleInfoRequest(userId: self.userId)

        self.dataTask = self.flickrServicable.getPeopleInfo(with: request) { result in
            switch result {
            case .success(let data):
                self.context.userId = data?.person.id ?? ""
                self.context.userName = data?.person.username.content ?? ""
                self.done()
            case .failure(let error):
                self.context.error = error
                self.errorCB(error)
            }
        }
    }
}
