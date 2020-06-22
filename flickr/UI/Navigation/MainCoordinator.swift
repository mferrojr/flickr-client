//
//  MainCoordinator.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//
import UIKit

class MainCoordinator: Coordinator {
    
    // MARK: - Variables
    
    // MARK: Private
    private var childCoordinators = [Coordinator]()
    private var navigationController: UINavigationController

    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Functions
    
    // MARK: Public
    func start() {
        let vc = PhotoCollectionViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func viewPhoto(of photo: PhotoCollectionModel) {
        let vc = PhotoDetailViewController(model: photo)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
}
