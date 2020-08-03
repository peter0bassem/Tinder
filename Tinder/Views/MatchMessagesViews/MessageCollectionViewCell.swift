//
//  MessageCollectionViewCell.swift
//  Tinder
//
//  Created by Peter Bassem on 8/2/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools

class MessageCollectionViewCell: LBTAListCell<Message> {
    
    // MARK: - UI Components
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 20)
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    private lazy var bubbleContainer: UIView = {
        let view = UIView(backgroundColor: #colorLiteral(red: 0.9005706906, green: 0.9012550712, blue: 0.9006766677, alpha: 1))
        view.layer.cornerRadius = 12
        return view
    }()
    
    // MARK: - Variables
    var bubbleAnchoredConstraints: AnchoredConstraints!
    override var item: Message! {
        didSet {
            textView.text = item.text
            if item.isFromCurrentLoggedUser {
                // right edge
                bubbleAnchoredConstraints.leading?.isActive = false
                bubbleAnchoredConstraints.trailing?.isActive = true
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.1471898854, green: 0.8059007525, blue: 0.9965714812, alpha: 1)
                textView.textColor = .white
            } else {
                bubbleAnchoredConstraints.trailing?.isActive = false
                bubbleAnchoredConstraints.leading?.isActive = true
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.9005706906, green: 0.9012550712, blue: 0.9006766677, alpha: 1)
                textView.textColor = .black
            }
        }
    }
    
    // MARK: - UICollectionViewCell Lifecycle
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleContainer)
        bubbleAnchoredConstraints = bubbleContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        bubbleAnchoredConstraints.leading?.constant = 20
        bubbleAnchoredConstraints.trailing?.constant = -20
        bubbleAnchoredConstraints.trailing?.isActive = false
        
//        bubbleAnchoredConstraints.leading?.isActive = false
//        bubbleAnchoredConstraints.trailing?.isActive = true
        
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
}
