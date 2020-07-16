//
//  PhotoCollectionTable.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionTable: NSObject {
    
    // MARK: - Variables

    // MARK: Public

    // MARK: Private
    private weak var owner: PhotoCollectionViewController?
    private var viewModel: PhotoCollectionViewModel

    // MARK: - Initializations
    init(viewModel: PhotoCollectionViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Functions
    
    // MARK: Public
    func setup(_ owner: PhotoCollectionViewController) {
        self.owner = owner
        let tableView = owner.tableView

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(
            UINib(nibName: PhotoCollectionTableViewCell.ReuseId, bundle: Bundle.main),
            forCellReuseIdentifier: PhotoCollectionTableViewCell.ReuseId
        )
    }
    
}

// MARK: - Extensions

// MARK: UITableViewDelegate
extension PhotoCollectionTable: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.viewModel.cancelFetchData()
        
        self.owner?.photoSelected(of: self.viewModel.entity(at: indexPath.row))
    }

}

// MARK: UITableViewDataSource
extension PhotoCollectionTable: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.totalCount > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.totalCount
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCollectionTableViewCell.ReuseId, for: indexPath) as? PhotoCollectionTableViewCell else {
            fatalError("Dequeued cell is not the expected type.")
        }

        if self.viewModel.isLoadingCell(for: indexPath) {
            cell.configure(with: .none, at: indexPath)
        } else {
            cell.configure(with: viewModel.entity(at: indexPath.row), at: indexPath)
        }

        return cell
    }
    
}
