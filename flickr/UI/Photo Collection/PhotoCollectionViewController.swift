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
    
    private lazy var landingLabel: UILabel = {
        return UILabel()
    }()
    
    
    
    private lazy var signInOrOutButton: UIBarButtonItem = {
        return UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(signInPressed)
        )
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .large)
    }()
    
    // MARK: - Initialization
    init() {
        self.viewModel = PhotoCollectionViewModel(
            flickrServicable: Services.flickrService,
            oauthable: Services.oauth
        )
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
        self.updateBackgroundText()
    }
    
    // MARK: - Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.signInOrOutButton.title = Environment.shared.isSignedIn ? "Sign Out" : "Sign In"
    }
       
    // MARK: Public
    func photoSelected(of photo: PhotoEntity) {
        self.coordinator?.viewPhoto(of: photo)
    }

    // MARK: Private
    private func buildNavigationBar() {
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = signInOrOutButton
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
        self.landingView.addSubview(self.landingLabel)
        self.landingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.landingLabel.centerYAnchor.constraint(equalTo: self.landingView.centerYAnchor).isActive = true
        self.landingLabel.centerXAnchor.constraint(equalTo: self.landingView.centerXAnchor).isActive = true
        self.tableView.backgroundView = self.landingView
    }
    
    private func setUpActivityIndicator() {
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    @objc
    private func signInPressed(_ btn: UIButton) {
        self.viewModel.signInOrOut()
    }
    
}

// MARK: - Extensions

// MARK: PRListViewModelDelegate
extension PhotoCollectionViewController: PhotoCollectionViewModelDelegate {
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        self.activityIndicator.stopAnimating()
        self.updateBackgroundText()
        
        guard let newIndexPathsToReload = newIndexPathsToReload else {
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
    
    func onSignInCompleted() {
        self.signInOrOutButton.title = "Sign Out"
    }
    
    func onSignInFailed() {
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Warning", message: "Unable to sign in to Flickr", actions: [action])
    }
    
    func onSignOutCompleted() {
        self.signInOrOutButton.title = "Sign In"
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

// MARK: UISearchResultsUpdatingroc
extension PhotoCollectionViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if let _ = self.searchText(), self.viewModel.totalCount == 0 {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        
        self.viewModel.reset()
        self.updateBackgroundText()
        
        guard let searchText = self.searchText() else { return }
        
        self.viewModel.fetchPhotos(by: searchText)
        self.landingView.isHidden = true
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

// MARK: Helpers
private extension PhotoCollectionViewController {

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    func searchText() -> String? {
        guard let searchText = self.searchController?.searchBar.text, searchText.count > 0 else {
            return nil
        }
        return searchText
    }
    
    func updateBackgroundText() {
        if let _ = searchText() {
            self.landingLabel.text = "No Results"
            self.landingView.isHidden = self.viewModel.totalCount > 0
        } else {
            self.landingLabel.text = "Find Your Inspiration"
            self.landingView.isHidden = false
        }
    }
}
