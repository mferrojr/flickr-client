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
    private var model: PhotoCollectionModel
    private let padding: CGFloat = 20
    private let commentsPlaceholder = "Add a Comment"
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bounces = false
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .boldSystemFont(ofSize: 17)
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingMiddle
        return view
    }()
    
    private lazy var photoImageView: FlickrImageView = {
        let view = FlickrImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var authorLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13)
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingMiddle
        return view
    }()
    
    private lazy var commentsTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
        view.textAlignment = .justified
        view.text = commentsPlaceholder
        view.textColor = .lightGray
        view.delegate = self
        return view
    }()
    
    private lazy var submitButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Submit", for: .normal)
        view.setTitleColor(.systemBlue, for: .normal)
        view.addTarget(self, action:#selector(self.submitPressed), for: .touchUpInside)
        return view
    }()
    
    // MARK: - Initialization
    init(model: PhotoCollectionModel) {
        self.viewModel = PhotoDetailViewModel(
            flickrServicable: Services.flickrService,
            oauthable: Services.oauth
        )
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        super.loadView()
        self.viewModel.delegate = self
        self.setUpScrollView()
        self.setUpHeaderLabel()
        self.setUpPhotoImage()
        self.setUpAuthorLabel()
        self.setUpCommentsTextView()
        self.setUpSubmit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerLabel.text = self.model.photo.title
        self.authorLabel.text = "Author: \(self.model.person?.userName ?? "N/A")"
        guard let url = self.model.photo.mediumPhotoUrl else { return }
        self.photoImageView.load(url: url)
        self.setSubmitBtn(enabled: false)
    }
    
    // MARK: - Functions
    
    // MARK: Private
    @objc
    private func submitPressed(_ sender: UIButton) {
        self.viewModel.add(by: self.model.photo.id, with: self.commentsTextView.text)
    }
    
    private func setUpScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    private func setUpHeaderLabel(){
        self.scrollView.addSubview(self.headerLabel)
        self.headerLabel.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: padding).isActive = true
        self.headerLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.headerLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
    }
    
    private func setUpPhotoImage(){
        self.scrollView.addSubview(self.photoImageView)
        self.photoImageView.topAnchor.constraint(equalTo: self.headerLabel.bottomAnchor, constant: padding).isActive = true
        self.photoImageView.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
        self.photoImageView.heightAnchor.constraint(equalToConstant: 150).isActive  = true
    }
    
    private func setUpAuthorLabel(){
        self.scrollView.addSubview(self.authorLabel)
        self.authorLabel.topAnchor.constraint(equalTo: self.photoImageView.bottomAnchor, constant: padding).isActive = true
        self.authorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.authorLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
    }
    
    private func setUpCommentsTextView(){
        self.scrollView.addSubview(self.commentsTextView)
        self.commentsTextView.topAnchor.constraint(equalTo: self.authorLabel.bottomAnchor, constant: padding).isActive = true
        self.commentsTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.commentsTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
        self.commentsTextView.heightAnchor.constraint(equalToConstant: 100).isActive  = true
    }
    
    private func setUpSubmit(){
        self.scrollView.addSubview(self.submitButton)
        self.submitButton.topAnchor.constraint(equalTo: self.commentsTextView.bottomAnchor, constant: padding).isActive = true
        self.submitButton.heightAnchor.constraint(equalToConstant: 30).isActive  = true
        self.submitButton.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.submitButton.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
    }
    
    private func setSubmitBtn(enabled: Bool) {
        self.submitButton.isEnabled = enabled
        self.submitButton.alpha = enabled ? 1.0 : 0.5
    }

}

// MARK: - Extensions

// MARK: PhotoDetailViewControllerDelegate
extension PhotoDetailViewController: PhotoDetailViewModelDelegate {
    
    func onSubmitFailed(with reason: String) {
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Warning", message: reason, actions: [action])
    }
    
    func onSubmitCompleted() {
        self.commentsTextView.text = ""
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Success", message: "You've added a comment!", actions: [action])
    }
    
    func onSignInFailed() {
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Warning", message: "Unable to sign in to Flickr", actions: [action])
    }
    
}

// MARK: UITextViewDelegate
extension PhotoDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard self.commentsTextView.textColor == .lightGray else { return }
        self.commentsTextView.text = ""
        self.commentsTextView.textColor = .black
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.setSubmitBtn(enabled: textView.text.count > 0 && textView.text != commentsPlaceholder)
    }
    
}
