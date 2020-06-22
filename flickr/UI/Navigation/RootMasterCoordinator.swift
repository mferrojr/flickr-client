//
//  RootMasterCoordinator.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation
import UIKit

final class RootMasterCoordinator: Coordinator {
    
    // MARK: - Variables
    
    // MARK: Private
    private weak var window: UIWindow?
    private var mainCoordinator: Coordinator?
    
    // MARK: - Initialization
    init(window: UIWindow?) {
        self.window = window
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func start() {
        let navController = UINavigationController()
        self.mainCoordinator = MainCoordinator(navigationController: navController)
        self.mainCoordinator?.start()
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }

}

