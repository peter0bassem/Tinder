//
//  HomeTopNavigationStackView.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class HomeTopNavigationStackView: UIStackView {
    
    // MARK : - UI Components
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(onSettingsButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var fireImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "app_icon").withRenderingMode(.alwaysOriginal))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(onMessageButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Variables
    var settingsButtonPressed: (() -> Void)?
    var messageButtonPressed: (() -> Void)?

    // MARK: - UIView Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [settingsButton, UIView(), fireImageView, UIView(), messageButton].forEach { addArrangedSubview($0) }
        distribution = .equalCentering
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
    @objc private func onSettingsButtonPressed(_ sender: UIButton) {
        settingsButtonPressed?()
    }
    
    @objc private func onMessageButtonPressed(_ sender: UIButton) {
        messageButtonPressed?()
    }
}
