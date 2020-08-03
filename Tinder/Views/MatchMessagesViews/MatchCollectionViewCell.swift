//
//  MatchCollectionViewCell.swift
//  Tinder
//
//  Created by Peter Bassem on 8/1/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools

class MatchCollectionViewCell: LBTAListCell<Match> {
    
    static let identifier = "MatchCollectionViewCell"
    
    // MARK: - UI Components
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"), contentMode: .scaleAspectFill)
        imageView.clipsToBounds = true
        imageView.constrainWidth(80)
        imageView.constrainHeight(80)
        imageView.layer.cornerRadius = 80 / 2
        return imageView
    }()
    private lazy var usernameLabel: UILabel = {
        let label = UILabel(text: "Username Here", font: .systemFont(ofSize: 14, weight: .semibold), textColor: #colorLiteral(red: 0.2550676465, green: 0.2552897036, blue: 0.2551020384, alpha: 1), textAlignment: .center, numberOfLines: 2)
        return label
    }()
    
    // MARK: - Variables
    override var item: Match! {
        didSet {
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl), placeholderImage: #imageLiteral(resourceName: "photo_placeholder").withRenderingMode(.alwaysOriginal), options: .continueInBackground)
            usernameLabel.text = item.name
        }
    }
    
    // MARK: - UICollectionViewCell Lifecycle
    
    // MARK: - Helpers
    override func setupViews() {
        super.setupViews()
        stack(stack(profileImageView, alignment: .center), usernameLabel)
    }
    
    // MARK: - Actions
}
