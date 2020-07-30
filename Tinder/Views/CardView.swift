//
//  CardView.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import SDWebImage

class CardView: UIView {
    
    // MARK: - UI Components
    private lazy var barsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        return gradientLayer
    }()
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    // MARK: - Variables
    private let threshold: CGFloat = 80
    private let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    
    var cardViewModel: CardViewModel! {
        didSet {
            let imageName = cardViewModel.imageNames.first ?? ""
            imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imageView.sd_setImage(with: URL(string: imageName))
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageNames.count).forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = .init(white: 0, alpha: 0.1)
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver()
        }
    }
    
    // MARK: - UIView Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = frame
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.fillSuperview()
        
        setupBarsStackview()
        
        // add a gradient layer
        layer.addSublayer(gradientLayer)
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
    }
    
    private func setupBarsStackview() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    
    private func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (index, imageUrl) in
            self?.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self?.imageView.sd_setImage(with: URL(string: imageUrl ?? ""))
            self?.barsStackView.arrangedSubviews.forEach { $0.backgroundColor = self?.barDeselectedColor }
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    // MARK: - Actions
    private func handleChanged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        // rotation
        // convert radian angle to degrees
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    private func handleEnded(_ sender: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = sender.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(sender.translation(in: nil).x) > threshold
        
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldDismissCard {
                
                // How to transform card off screen?
                //1
//                let offScreenTransform = self.transform.translatedBy(x: 1000, y: 0)
//                self.transform = offScreenTransform
                
                //2
//                self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height) // don't work on iOS 13!!
                self.center = CGPoint(x: 600 * translationDirection, y: 0)
                
            } else {
                self.transform = .identity
            }
        }) { (_) in
            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
//                self.superview?.sendSubviewToBack(self) // just for sending the removed card to the back of all other views for not showing empty view after removing all cards.
            }
//            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.size.width, height: self.superview!.frame.size.height)
        }
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            //            superview?.subviews.forEach { $0.layer.removeAllAnimations() }
            superview?.subviews.last?.layer.removeAllAnimations()
        case .changed:
            handleChanged(sender)
        case .ended:
            handleEnded(sender)
        default: ()
        }
    }
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > (frame.width / 2) ? true : false
        
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }
}
