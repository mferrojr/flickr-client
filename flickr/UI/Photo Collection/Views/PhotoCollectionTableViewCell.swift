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
    
    // MARK: - Initialization
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.reset()
        self.titleLabel.text = nil
    }

    // MARK: - Functions

    // MARK: Public
    func configure(with entity: PhotoEntity?, at indexPath: IndexPath) {
        guard let entity = entity else {
            self.titleLabel.text = nil
            return
        }

        self.titleLabel.text = entity.title
        
        guard let url = entity.mediumPhotoUrl else {
            return
        }
        self.photoImageView.load(url: url)
    }
    
   
    
}
