//
//  FlickrImageView.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/21/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Combine
import Foundation
import UIKit

// Reference: https://github.com/sgl0v/OnSwiftWings/blob/master/ImageCache.playground/Sources/MovieTableViewCell.swift
final class FlickrImageView: UIImageView {
 
    // MARK: - Variables
    
    // MARK: Private
    private var cancellable: AnyCancellable?
    private lazy var animator: UIViewPropertyAnimator = {
        return UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    }()
    
    // MARK: - Functions
    
    // MARK: Public
    func load(url: URL) {
        self.cancellable = self.loadImage(for: url)
            .sink { [weak self] image in
                self?.showImage(image:image)
            }
    }
    
    func reset() {
        self.image = nil
        self.alpha = 0.0
        self.animator.stopAnimation(true)
        self.cancellable?.cancel()
    }

}

// MARK: - Private Functions
private extension FlickrImageView {
    
    func showImage(image: UIImage?) {
        self.alpha = 0.0
        self.image = image
        self.animator.addAnimations { [weak self] in
           self?.alpha = 1.0
        }
        self.animator.startAnimation()
    }

    func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url.absoluteString)
        .flatMap({ photoUrl -> AnyPublisher<UIImage?, Never> in
           return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
    
}
