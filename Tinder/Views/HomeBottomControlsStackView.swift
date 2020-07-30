//
//  HomeBottomControlsStackView.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {
    
    // MARK: - UI Components
    private lazy var refreshButton: UIButton = {
        let button = self.createButton(with: #imageLiteral(resourceName: "refresh_circle"))
        button.addTarget(self, action: #selector(onRefreshButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var dislikeButton: UIButton = {
        return self.createButton(with: #imageLiteral(resourceName: "dismiss_circle"))
    }()
    private lazy var superLikeButton: UIButton = {
        return self.createButton(with: #imageLiteral(resourceName: "super_like_circle"))
    }()
    private lazy var likeButton: UIButton = {
        return self.createButton(with: #imageLiteral(resourceName: "like_circle"))
    }()
    private lazy var specialButton: UIButton = {
        return self.createButton(with: #imageLiteral(resourceName: "boost_circle"))
    }()
    
    // MARK: - Variables
    var refreshButtonPressed: (() -> Void)?
    
    // MARK: - UIView Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { addArrangedSubview($0) }
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func createButton(with image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    // MARK: - Actions
    @objc private func onRefreshButtonPressed(_ sender: UIButton) {
        refreshButtonPressed?()
    }
}
