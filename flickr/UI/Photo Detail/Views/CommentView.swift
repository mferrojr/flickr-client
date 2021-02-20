//
//  CommentView.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation
import UIKit

final class CommentView: UIView {
    
    // MARK: - Variables
    
    // MARK: Private
    private let padding: CGFloat = 16
    
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .boldSystemFont(ofSize: 13)
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var commentLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13)
        view.numberOfLines = 0
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: - Functions
    
    // MARK: Public
    func configure(with comment: CommentEntity) {
        self.nameLabel.text = comment.authorname
        self.commentLabel.text = comment.content
    }
    
}

// MARK: - Private Functions
private extension CommentView {
    
    // MARK: Private
    func setup() {
        self.addSubview(self.nameLabel)
        self.nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding).isActive = true
        self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding).isActive = true
        self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding).isActive = true
        
        self.addSubview(self.commentLabel)
        self.commentLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor).isActive = true
        self.commentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding).isActive = true
        self.commentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding).isActive = true
        self.commentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: padding).isActive = true
    }
    
}
