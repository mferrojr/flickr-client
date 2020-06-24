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
    
    // MARK: Constants
    private let padding: CGFloat = 20
    private let commentsPlaceholder = "Add a Comment"
    
    // MARK: Constraints
    private var descriptionTopConstraint: NSLayoutConstraint?
    private var descriptionBottomConstraint: NSLayoutConstraint?
    private var commentsTopConstraint: NSLayoutConstraint?
    private var commentsBottomConstraint: NSLayoutConstraint?
    
    // MARK: UI Elements
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
        view.font = .systemFont(ofSize: 15, weight: .semibold)
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingMiddle
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13, weight: .regular)
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var statsStackContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statsStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = 5
        return view
    }()
    
    private lazy var numFavesLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13)
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var numCommentsLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13)
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var separator1: SeparatorView = {
        let view = SeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separator2: SeparatorView = {
        let view = SeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private lazy var commentsStackContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var commentsStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .fill
        view.spacing = 10
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
        self.setUpDescriptionLabel()
        self.setUpSeparator1()
        self.setUpStatsStackContainer()
        self.setUpStatsStack()
        self.setUpSeparator2()
        self.setUpCommentsStackContainer()
        self.setUpCommentsStack()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.fetchMetadata(for: self.model.photo)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.cancelFetchData()
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
        self.photoImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    private func setUpAuthorLabel(){
        self.scrollView.addSubview(self.authorLabel)
        self.authorLabel.topAnchor.constraint(equalTo: self.photoImageView.bottomAnchor, constant: padding).isActive = true
        self.authorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.authorLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
    }
    
    private func setUpDescriptionLabel(){
        self.scrollView.addSubview(self.descriptionLabel)
        self.descriptionTopConstraint =
            self.descriptionLabel.topAnchor.constraint(equalTo: self.authorLabel.bottomAnchor, constant: 5)
        self.descriptionTopConstraint?.isActive = true
        self.descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
    }
    
    private func setUpSeparator1(){
        self.scrollView.addSubview(self.separator1)
        self.descriptionBottomConstraint = self.separator1.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 10)
        self.descriptionBottomConstraint?.isActive = true
        self.separator1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.separator1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
        self.separator1.heightAnchor.constraint(equalToConstant: 1).isActive  = true
    }
    
    private func setUpStatsStackContainer() {
        self.scrollView.addSubview(self.statsStackContainer)
        self.statsStackContainer.topAnchor.constraint(equalTo: self.separator1.bottomAnchor).isActive = true
        self.statsStackContainer.heightAnchor.constraint(equalToConstant: 30).isActive  = true
        self.statsStackContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.statsStackContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    private func setUpStatsStack(){
        self.statsStackContainer.addSubview(self.statsStack)
        self.statsStack.topAnchor.constraint(equalTo: self.statsStackContainer.topAnchor).isActive = true
        self.statsStack.bottomAnchor.constraint(equalTo: self.statsStackContainer.bottomAnchor).isActive = true
        self.statsStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.statsStack.addArrangedSubview(self.numFavesLabel)
        self.statsStack.addArrangedSubview(self.numCommentsLabel)
    }
    
    private func setUpSeparator2(){
        self.scrollView.addSubview(self.separator2)
        self.separator2.topAnchor.constraint(equalTo: self.statsStackContainer.bottomAnchor).isActive = true
        self.separator2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.separator2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
        self.separator2.heightAnchor.constraint(equalToConstant: 1).isActive  = true
    }
    
    private func setUpCommentsStackContainer(){
        self.scrollView.addSubview(self.commentsStackContainer)
        self.commentsTopConstraint = self.commentsStackContainer.topAnchor.constraint(equalTo: self.separator2.bottomAnchor)
        self.commentsTopConstraint?.isActive = true
        self.commentsStackContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.commentsStackContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    private func setUpCommentsStack(){
        self.commentsStackContainer.addSubview(self.commentsStack)
        self.commentsStack.topAnchor.constraint(equalTo: self.commentsStackContainer.topAnchor).isActive = true
        self.commentsStack.leadingAnchor.constraint(equalTo: self.commentsStackContainer.leadingAnchor).isActive = true
        self.commentsStack.trailingAnchor.constraint(equalTo: self.commentsStackContainer.trailingAnchor).isActive = true
        self.commentsStack.bottomAnchor.constraint(equalTo: self.commentsStackContainer.bottomAnchor).isActive = true
    }
    
    private func setUpCommentsTextView(){
        self.scrollView.addSubview(self.commentsTextView)
        self.commentsTextView.topAnchor.constraint(equalTo: self.commentsStackContainer.bottomAnchor, constant: padding).isActive = true
        self.commentsTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding).isActive = true
        self.commentsTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding).isActive = true
        self.commentsTextView.heightAnchor.constraint(equalToConstant: 75).isActive  = true
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
    
    func onSubmitCompleted(with comment: CommentEntity) {
        self.commentsTextView.text = ""
        self.addCommentToStack(with: comment)
        self.setCommentsCount()
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Success", message: "You've added a comment!", actions: [action])
    }
    
    func onSignInFailed() {
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Warning", message: "Unable to sign in to Flickr", actions: [action])
    }
    
    func onPhotoMetadataFetchCompleted(with data: PhotoDetailModel) {
        if data.description.count == 0 {
            self.descriptionTopConstraint?.constant = 5
            self.descriptionBottomConstraint?.constant = 0
        } else {
            self.descriptionLabel.text = data.description
        }
        
        self.numFavesLabel.text = "\(data.numOfFavorites) faves"
        
        for comment in data.comments {
            self.addCommentToStack(with: comment)
        }
        
        self.setCommentsCount()
    }
    
    func onPhotoMetadataFetchFailed(with reason: String) {
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: "Warning", message: "Unable to retrieve photo data", actions: [action])
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

// MARK: - Helpers
private extension PhotoDetailViewController {
    
    func addCommentToStack(with comment: CommentEntity) {
        let commentView = CommentView()
        commentView.configure(with: comment)
        self.commentsStack.addArrangedSubview(commentView)
    }
    
    func setCommentsCount() {
        self.numCommentsLabel.text = "\(self.commentsStack.arrangedSubviews.count) comments"
    }
    
}
