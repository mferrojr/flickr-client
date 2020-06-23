//
//  SeparatorView.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/23/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation
import UIKit

class SeparatorView: UIView {
    
    // MARK: - Variables
    
    // MARK: Private
    private lazy var separaterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
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
    
    // MARK: Private
    private func setup() {
        self.addSubview(self.separaterView)
        self.separaterView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.separaterView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.separaterView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.separaterView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
