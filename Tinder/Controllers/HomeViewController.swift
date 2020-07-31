//
//  HomeViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeViewController: UIViewController {
    
    // MARK : - UI Components
    private lazy var loadingHud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        return hud
    }()
    private lazy var topStackView: HomeTopNavigationStackView = {
        let stackView = HomeTopNavigationStackView()
        return stackView
    }()
    private lazy var cardsDeckView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var bottomControls: HomeBottomControlsStackView = {
        let stackView = HomeBottomControlsStackView()
        return stackView
    }()
    
    // MARK : - Variables
    var cardViewModels = [CardViewModel]()
    var lastFetchedUser: User?
    private var user: User?
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        setupTopStackViewActions()
        setupBottomControlsActions()
        fetchCurrentUser()
//        setupFirestoreUserCards()
//        fetchUsersFromFirestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            let registrationNavigationController = UINavigationController(rootViewController: loginViewController)
            registrationNavigationController.modalPresentationStyle = .fullScreen
            present(registrationNavigationController, animated: true)
        }
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    private func setupTopStackViewActions() {
        topStackView.settingsButtonPressed = { [weak self] in
            let settingsViewController = SettingsTableViewController()
            settingsViewController.delegate = self
            let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
            settingsNavigationController.modalPresentationStyle = .fullScreen
            self?.present(settingsNavigationController, animated: true)
        }
    }
    
    private func setupBottomControlsActions() {
        bottomControls.refreshButtonPressed = { [weak self] in
            self?.fetchUsersFromFirestore()
        }
    }
    
    private func fetchCurrentUser() {
        loadingHud.show(in: view)
        Firestore.firestore().fetchCurrentUser { [weak self] (user, error) in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            self?.user = user
            self?.fetchUsersFromFirestore()
        }
    }
    
    private func fetchUsersFromFirestore() {
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: user?.minSeekingAge ?? SettingsTableViewController.defaultMinSeekingAge).whereField("age", isLessThanOrEqualTo: user?.maxSeekingAge ?? SettingsTableViewController.defaultMaxSeekingAge)
        query.getDocuments { [weak self] (snapshot, error) in
            self?.loadingHud.dismiss()
            if let error = error {
                print("Failed to fetch users:", error)
                return
            }
            snapshot?.documents.forEach {
                let user = User(dictionary: $0.data())
                if user.uid != Auth.auth().currentUser?.uid {
                    self?.setupCard(from: user)
                }
//                self?.cardViewModels.append(user.toCardViewModel())
//                self?.lastFetchedUser = user
            }
        }
    }
    
    private func setupCard(from user: User) {
        let cardView = CardView()
        cardView.cardViewModel = user.toCardViewModel()
        cardView.delegate = self
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
    }
    
    private func setupFirestoreUserCards() {
        cardViewModels.forEach { (cardViewModel) in
            let cardView = CardView()
            cardView.cardViewModel = cardViewModel
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
}


// MARK: - SettingsTableViewControllerDelegate
extension HomeViewController: SettingsTableViewControllerDelegate {
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
}

// MARK: - LoginViewControllerDelegate
extension HomeViewController: LoginViewControllerDelegate {
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
}

// MARK: - CardViewDelegate
extension HomeViewController: CardViewDelegate {
    
    func cardViewDidTapMoreInfo(with cardViewModel: CardViewModel) {
        let userDetailsViewController = UserDetailsViewController()
        userDetailsViewController.modalPresentationStyle = .fullScreen
        userDetailsViewController.cardViewModel = cardViewModel
        present(userDetailsViewController, animated: true)
    }
}
