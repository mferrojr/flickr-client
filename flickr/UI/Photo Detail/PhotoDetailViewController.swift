//
//  PhotoDetailViewController.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    // MARK: - Variables
    
    // MARK: Public
    weak var coordinator: MainCoordinator?
    
    // MARK: Private
    private var viewModel: PhotoDetailViewModel
    private var photoEntity: PhotoEntity
    
    // MARK: - Initialization
    init(photoEntity: PhotoEntity) {
        self.viewModel = PhotoDetailViewModel()
        self.photoEntity = photoEntity
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        super.loadView()
        self.viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - Extensions

// MARK: PhotoDetailViewControllerDelegate
extension PhotoDetailViewController: PhotoDetailViewModelDelegate {
}
