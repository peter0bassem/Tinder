//
//  MessagesNavigationBar.swift
//  Tinder
//
//  Created by Peter Bassem on 8/2/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools

class MessagesNavigationBar: UIView {
    
    // MARK: - UI Components
    private lazy var userProfileImageView: CircularImageView = {
        let imageView = CircularImageView(width: 44, image: #imageLiteral(resourceName: "jane1.jpg"))
        return imageView
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel(text: "USERNAME", font: .systemFont(ofSize: 16))
        return label
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(image: #imageLiteral(resourceName: "back"), tintColor: #colorLiteral(red: 0.9792197347, green: 0.2754820287, blue: 0.3579338193, alpha: 1), target: self, action: #selector(onBackButtonPressed(_:)))
        return button
    }()
    private lazy var flagButton: UIButton = {
        let button = UIButton(image: #imageLiteral(resourceName: "flag"), tintColor: #colorLiteral(red: 0.9792197347, green: 0.2754820287, blue: 0.3579338193, alpha: 1), target: self, action: #selector(onFlagButtonPressed(_:)))
        return button
    }()
    private lazy var customNavigationBar: UIView = {
        let view = UIView(backgroundColor: .white)
        view.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        let middleStackView = view.hstack(
            view.stack(self.userProfileImageView, self.nameLabel, spacing: 8,alignment: .center),
            alignment: .center
        )
        view.hstack(self.backButton.withWidth(50), middleStackView, self.flagButton)
        return view
    }()
    
    // MARK: - Variables
    private let match: Match
    
    var backButtonPressed: (() -> Void)?
    
    // MARK: - UIView Lifecycle
    init(match: Match) {
        self.match = match
        super.init(frame: .zero)
        
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl), placeholderImage: #imageLiteral(resourceName: "photo_placeholder").withRenderingMode(.alwaysOriginal))
        nameLabel.text = match.name
        
        addSubview(customNavigationBar)
        customNavigationBar.fillSuperview(padding: .init(top: 0, left: 4, bottom: 0, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
    @objc private func onBackButtonPressed(_ sender: UIButton) {
        backButtonPressed?()
    }
    
    @objc private func onFlagButtonPressed(_ sender: UIButton) {
    }
}
