//
//  MatchesNavigationBar.swift
//  Tinder
//
//  Created by Peter Bassem on 8/1/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class MatchesNavigationBar: UIView {
    
    // MARK: - UI Components
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "top_messages_icon").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        imageView.tintColor = #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1)
        return imageView
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(image: #imageLiteral(resourceName: "app_icon"), tintColor: .lightGray)
        button.addTarget(self, action: #selector(onBackButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var messagesLabel: UILabel = {
        let label = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1), textAlignment: .center)
        return label
    }()
    private lazy var feedLabel: UILabel = {
        let label = UILabel(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
        return label
    }()
    private lazy var customNavigationBar: UIView = {
        let view = UIView(backgroundColor: .white)
        view.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        view.stack(iconImageView.withHeight(44),
                   view.hstack(messagesLabel, feedLabel, distribution: .fillEqually)).padTop(10)
        return view
    }()
    
    // MARK: - Variables
    var backButtonPressed: (() -> Void)?
    
    // MARK: - UIView Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(customNavigationBar)
        customNavigationBar.fillSuperview()
        
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 34, height: 34))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
    @objc private func onBackButtonPressed(_ sender: UIButton) {
        backButtonPressed?()
    }
}
