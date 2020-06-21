//
//  PhotoCollectionTableViewCell.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/20/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Combine
import UIKit

protocol PhotoCollectionTableViewCellDelegate: class {
    func updateAt(indexPath: IndexPath)
}

// Reference: https://github.com/sgl0v/OnSwiftWings/blob/master/ImageCache.playground/Sources/MovieTableViewCell.swift
class PhotoCollectionTableViewCell: UITableViewCell {

    // MARK: - Variables

    // MARK: Public
    weak var delegate: PhotoCollectionTableViewCellDelegate?
    static let ReuseId = String(describing: PhotoCollectionTableViewCell.self)

    // MARK: Private
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var cancellable: AnyCancellable?
    private lazy var animator: UIViewPropertyAnimator = {
        return UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    }()
    
    // MARK: - Initialization
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
        self.photoImageView.alpha = 0.0
        self.animator.stopAnimation(true)
        self.cancellable?.cancel()
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
        self.cancellable = self.loadImage(for: entity)
            .sink { [weak self] image in
                self?.showImage(image:image)
            }
    }
    
    // MARK: Private
    private func showImage(image: UIImage?) {
        self.photoImageView.alpha = 0.0
        self.photoImageView.image = image
        self.animator.addAnimations { [weak self] in
            self?.photoImageView.alpha = 1.0
        }
        self.animator.startAnimation()
    }
    
    private func loadImage(for photo: PhotoEntity) -> AnyPublisher<UIImage?, Never> {
        return Just(photo.mediumPhotoUrl)
        .flatMap({ photoUrl -> AnyPublisher<UIImage?, Never> in
            let url = URL(string: photo.mediumPhotoUrl)!
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
    
}
