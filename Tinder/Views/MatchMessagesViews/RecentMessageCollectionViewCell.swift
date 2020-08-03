//
//  RecentMessageCollectionViewCell.swift
//  Tinder
//
//  Created by Peter Bassem on 8/3/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools
import SDWebImage

class RecentMessageCollectionViewCell: LBTAListCell<RecentMessage> {
    
    // MARK: - UI Components
    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "jane1.jpg"), contentMode: .scaleAspectFill)
        imageView.constrainWidth(94)
        imageView.constrainHeight(94)
        imageView.layer.cornerRadius = 94 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var usernameLabel: UILabel = {
        let label = UILabel(text: "USERNAME HERE", font: .boldSystemFont(ofSize: 18))
        return label
    }()
    private lazy var messageTextLabel: UILabel = {
        let label = UILabel(text: "Some long line of text that should span 2 lines", font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 2)
        return label
    }()
    
    // MARK: - Variables
    override var item: RecentMessage! {
        didSet {
            userProfileImageView.sd_setImage(with: URL(string: item.profileImageUrl), placeholderImage: #imageLiteral(resourceName: "photo_placeholder").withRenderingMode(.alwaysOriginal))
            usernameLabel.text = item.name
            messageTextLabel.text = item.text
        }
    }
    
    //MARK: - UICollectionViewCell Lifecycle
    override func setupViews() {
        super.setupViews()
        
        hstack(userProfileImageView,
               stack(usernameLabel, messageTextLabel, spacing: 2),
               spacing: 20,
               alignment: .center
            ).padLeft(20).padRight(20)
        addSeparatorView(leadingAnchor: usernameLabel.leadingAnchor)
    }
}
