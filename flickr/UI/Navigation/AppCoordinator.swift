//
//  AppCoordinator.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    
    // MARK: - Variables
    
    // MARK: Private
    private weak var window: UIWindow?
    private var rootMasterCoordinator: Coordinator?
    
    // MARK: - Initialization
    init(window: UIWindow) {
        self.window = window
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func start() {
        self.rootMasterCoordinator = RootMasterCoordinator(window: window)
        self.rootMasterCoordinator?.start()
    }
}

