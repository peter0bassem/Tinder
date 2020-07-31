//
//  UserDetailsViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/31/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import SDWebImage

class UserDetailsViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        return scrollView
    }()
    private lazy var swipingPhotoPageViewController: SwipingPhotosPageViewController = {
        let viewController = SwipingPhotosPageViewController()
        return viewController
    }()
    private var swipingPhotoPageViewControllerView: UIView {
        return swipingPhotoPageViewController.view
    }
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(onDismissButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        return visualEffectView
    }()
    private lazy var dislikeButton: UIButton = {
        return createButton(with: #imageLiteral(resourceName: "dismiss_circle"), action: #selector(onDislikeButtonPressed(_:)))
    }()
    private lazy var superLikeButton: UIButton = {
        return createButton(with: #imageLiteral(resourceName: "super_like_circle"), action: #selector(onSuperLikeButtonPressed(_:)))
    }()
    private lazy var likeButton: UIButton = {
        return createButton(with: #imageLiteral(resourceName: "like_circle"), action: #selector(onLikeButtonPressed(_:)))
    }()
    
    // MARK: - Variables
    var cardViewModel: CardViewModel! {
        didSet {
            swipingPhotoPageViewController.cardViewModel = cardViewModel
            infoLabel.attributedText = cardViewModel.attributedString
        }
    }
    private let extraSwipingHeight: CGFloat = 80
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupLayout()
        setupVisualBlurEffectView()
        setupBottomControls()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        swipingPhotoPageViewControllerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: (view.frame.size.width + extraSwipingHeight))
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        scrollView.addSubview(swipingPhotoPageViewControllerView)
        swipingPhotoPageViewControllerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingPhotoPageViewControllerView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingPhotoPageViewControllerView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 24), size: .init(width: 50, height: 50))
    }
    
    private func setupVisualBlurEffectView() {
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func createButton(with image: UIImage, action selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    @objc private func onDismissButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func onDislikeButtonPressed(_ sender: UIButton) {
        print("Disliking")
    }
    
    @objc private func onSuperLikeButtonPressed(_ sender: UIButton) {
        print("Super Liking")
    }
    
    @objc private func onLikeButtonPressed(_ sender: UIButton) {
        print("Liking")
    }
}

// MARK: - UIScrollViewDelegate
extension UserDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = (view.frame.size.width + (changeY * 2))
        width = max(view.frame.size.width, width)
        
        swipingPhotoPageViewControllerView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: (width + extraSwipingHeight))
    }
}
