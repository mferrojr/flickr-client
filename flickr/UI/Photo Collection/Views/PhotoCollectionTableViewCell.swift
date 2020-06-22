//
//  PhotoCollectionTableViewCell.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/20/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Combine
import UIKit


class PhotoCollectionTableViewCell: UITableViewCell {

    // MARK: - Variables

    // MARK: Public
    static let ReuseId = String(describing: PhotoCollectionTableViewCell.self)

    // MARK: Private
    @IBOutlet private weak var photoImageView: FlickrImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var userName: UILabel!
    
    // MARK: - Initialization
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.reset()
        self.titleLabel.text = nil
        self.userName.text = nil
    }

    // MARK: - Functions

    // MARK: Public
    func configure(with entity: PhotoCollectionModel?, at indexPath: IndexPath) {
        guard let entity = entity else {
            self.titleLabel.text = nil
            self.userName.text = nil
            return
        }

        self.titleLabel.text = entity.photo.title
        self.userName.text = "Author: \(entity.person?.userName ?? "N/A")"
        
        guard let url = entity.photo.mediumPhotoUrl else {
            return
        }
        self.photoImageView.load(url: url)
    }
    
   
    
}
