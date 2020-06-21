//
//  PhotoCollectionViewController.swift
//  flickr
//
//  Created by Michael Ferro, Jr. on 6/19/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import UIKit

class PhotoCollectionViewController: UIViewController {

    // MARK: - Variables
    
    // MARK: Public
    weak var coordinator: MainCoordinator?

    lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: Private
    fileprivate var searchController: UISearchController?
    private let table: PhotoCollectionTable
    private var viewModel: PhotoCollectionViewModel
    
    private lazy var landingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var signInButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign In", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .large)
    }()
    
    // MARK: - Initialization
    init() {
        self.viewModel = PhotoCollectionViewModel(flickrServicable: Services.flickrService)
        self.table = PhotoCollectionTable(viewModel: self.viewModel)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        super.loadView()
        self.viewModel.delegate = self
        self.table.setup(self)
        self.navigationItem.title = "Flickr"
        self.tableView.prefetchDataSource = self
        self.buildNavigationBar()
        self.setUpSearchController()
        self.setUpTableView()
        self.setUpLandingView()
        self.setUpActivityIndicator()
    }
    
    // MARK: - Functions
       
    // MARK: Public
    func photoSelected(of photo: PhotoEntity) {
        self.coordinator?.viewPhoto(of: photo)
    }

     // MARK: Private
    private func buildNavigationBar() {
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: self.signInButton)
        ]
    }
    
    private func setUpSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.delegate = self
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchResultsUpdater = self
        self.searchController?.searchBar.sizeToFit()
        self.searchController?.searchBar.placeholder = "Search By Tag"
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
    }
    
    private func setUpTableView() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.tableView.tableHeaderView = UIView(frame: .zero)
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setUpLandingView() {
        let label = UILabel()
        label.text = "Find Your Inspiration"
        self.landingView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: self.landingView.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: self.landingView.centerXAnchor).isActive = true
        self.tableView.backgroundView = self.landingView
    }
    
    private func setUpActivityIndicator() {
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }

}

// MARK: - Extensions

// MARK: PRListViewModelDelegate
extension PhotoCollectionViewController: PhotoCollectionViewModelDelegate {
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
              activityIndicator.stopAnimating()
              tableView.isHidden = false
              tableView.reloadData()
              return
        }
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        self.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        self.activityIndicator.stopAnimating()
        
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Warning", message: reason, actions: [action])
    }
    
}

// MARK: UISearchControllerDelegate
extension PhotoCollectionViewController: UISearchControllerDelegate {

    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
}

// MARK: UISearchBarDelegate
extension PhotoCollectionViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count == 0 else { return }
        self.viewModel.reset()
        self.landingView.isHidden = false
        self.tableView.reloadData()
    }

}

// MARK: UISearchResultsUpdating
extension PhotoCollectionViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = self.searchText() else { return }
        if self.viewModel.totalCount == 0 {
            self.activityIndicator.startAnimating()
        }
        self.landingView.isHidden = self.viewModel.totalCount == 0
        self.viewModel.fetchPhotos(by: searchText)
    }

}

// MARK: UITableViewDataSourcePrefetching
extension PhotoCollectionViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard indexPaths.contains(where: self.viewModel.isLoadingCell) else { return }
        guard let searchText = self.searchText() else { return }
        self.viewModel.fetchPhotos(by: searchText)
    }
    
}

// MARK: PhotoCollectionTableViewCellDelegate
extension PhotoCollectionViewController: PhotoCollectionTableViewCellDelegate {
    
    func updateAt(indexPath: IndexPath) {
        //DispatchQueue.main.async {
            self.tableView.beginUpdates()
            /*self.tableView.reloadRows(
                at: [indexPath],
                with: .fade)*/
            self.tableView.endUpdates()
        //}
    }
}


private extension PhotoCollectionViewController {

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    func searchText() -> String? {
        guard let searchText = self.searchController?.searchBar.text, searchText.count > 2 else {
            return nil
        }
        return searchText
    }
}