//
//  MatchesHeaderCollectionReusableView.swift
//  Tinder
//
//  Created by Peter Bassem on 8/3/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools

class MatchesHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - UI Components
    private lazy var newMatchesLabel: UILabel = {
        let label = UILabel(text: "New Matches", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 0.9826375842, green: 0.3476698399, blue: 0.447683692, alpha: 1))
        return label
    }()
    private lazy var matchesCollectionViewController: MatchesHorizontalCollectionViewController = {
        let viewController = MatchesHorizontalCollectionViewController()
        return viewController
    }()
    private lazy var messagesLabel: UILabel = {
        let label = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 0.9826375842, green: 0.3476698399, blue: 0.447683692, alpha: 1))
        return label
    }()
    
    // MARK: - Variabels
    weak var rootMessagesViewController: MatchesMessagesCollectionViewController? {
        didSet {
            matchesCollectionViewController.rootMessagesViewController = rootMessagesViewController
            
        }
    }
    
    // MARK: - UICollectionReusableView Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stack(
            stack(newMatchesLabel).padLeft(20),
            matchesCollectionViewController.view,
            stack(messagesLabel).padLeft(20)
            , spacing: 20).withMargins(.init(top: 0, left: 20, bottom: 8, right: 0))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
}
