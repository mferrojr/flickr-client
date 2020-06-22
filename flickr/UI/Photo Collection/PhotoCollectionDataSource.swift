//
//  PhotoCollectionDataSource.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionDataSource: NSObject {
    
    // MARK: - Variables
    
    // MARK: Private
    //private(set) var datas = [GitHubPREntity]()
    //private let gitHubPREntityService: GitHubPREntityServicable
    
    // MARK: - Initialization
    /*init(prService: GitHubPREntityServicable) {
        self.gitHubPREntityService = prService
    }*/
    
    // MARK: - Functions
    
    // MARK: Public
    func refresh(){
        //datas = gitHubPREntityService.fetchAll(sorted: Sorted(key: "number", ascending: false))
    }
    
   
    
    // MARK: Private
}

// MARK: - Extensions

// MARK: UITableViewDataSource
/*extension PhotoCollectionDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: PRTableViewCell.ReuseId, for: indexPath) as? PRTableViewCell else {
           fatalError("Dequeued cell is not the expected type.")
       }

       let model = datas[indexPath.row]
       
       var subTitle = "#\(model.number)"
       if let login = model.user?.login {
           subTitle.append(" by \(login)")
       }
       cell.configure(PRTableViewCellModel(title: model.title, subTitle: subTitle))

       return cell
    }
}
*/
