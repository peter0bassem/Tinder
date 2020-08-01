//
//  CardView.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate: class {
    func cardViewDidTapMoreInfo(with cardViewModel: CardViewModel)
    func cardViewDidRemoveCardView(_ cardView: CardView)
    func cardViewDidLikeSwipe()
    func cardViewDidDislikeSwipe()
}

class CardView: UIView {

    // MARK: - UI Components
    private lazy var barsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    private lazy var swipingPhotosPageViewController: SwipingPhotosPageViewController = {
        let swipingPhotosPageViewController = SwipingPhotosPageViewController(isCardViewMode: true)
        return swipingPhotosPageViewController
    }()
    private var swipingPhotosPageViewControllerView: UIView {
        return swipingPhotosPageViewController.view
    }
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
    private lazy var moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(onMoreInfoButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Variables
    private let threshold: CGFloat = 80
    private let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    weak var delegate: CardViewDelegate?
    var nextCardView: CardView?

    var cardViewModel: CardViewModel! {
        didSet {
            swipingPhotosPageViewController.cardViewModel = cardViewModel
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment

            if cardViewModel.imageUrls.count > 1 {
                (0..<cardViewModel.imageUrls.count).forEach { (_) in
                    let barView = UIView()
                    barView.backgroundColor = .init(white: 0, alpha: 0.1)
                    barsStackView.addArrangedSubview(barView)
                }
                barsStackView.arrangedSubviews.first?.backgroundColor = .white
            }
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

        addSubview(swipingPhotosPageViewControllerView)
        swipingPhotosPageViewControllerView.fillSuperview()

        // add a gradient layer
        layer.addSublayer(gradientLayer)

        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))

        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }

    private func setupBarsStackview() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }

    private func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (index, imageUrl) in
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

        if shouldDismissCard {
            if translationDirection == 1 {
                delegate?.cardViewDidLikeSwipe()
            } else {
                delegate?.cardViewDidDislikeSwipe()
            }
            isUserInteractionEnabled = false
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        }
        
        

//        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
//            if shouldDismissCard {
//
//                // How to transform card off screen?
//                //1
//                //                let offScreenTransform = self.transform.translatedBy(x: 1000, y: 0)
//                //                self.transform = offScreenTransform
//
//                //2
//                //                self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height) // don't work on iOS 13!!
//                self.center = CGPoint(x: 600 * translationDirection, y: 0)
//
//            } else {
//                self.transform = .identity
//            }
//        }) { (_) in
//            self.transform = .identity
//            if shouldDismissCard {
//                self.removeFromSuperview()
//                self.delegate?.cardViewDidRemoveCardView(self)
//                //                self.superview?.sendSubviewToBack(self) // just for sending the removed card to the back of all other views for not showing empty view after removing all cards.
//            }
//            //            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.size.width, height: self.superview!.frame.size.height)
//        }
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

    @objc private func onMoreInfoButtonPressed(_ sender: UIButton) {
        delegate?.cardViewDidTapMoreInfo(with: cardViewModel)
    }
}
