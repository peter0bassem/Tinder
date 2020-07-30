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
        hud.textLabel.text = "Fetching Users"
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
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        setupFirestoreUserCards()
        fetchUsersFromFirestore()
        setupTopStackViewActions()
        setupBottomControlsActions()
    }
    
    private func setupTopStackViewActions() {
        topStackView.settingsButtonPressed = { [weak self] in
            let registrationController = RegistrationViewController()
            registrationController.modalPresentationStyle = .fullScreen
            self?.present(registrationController, animated: true)
        }
    }
    
    private func setupBottomControlsActions() {
        bottomControls.refreshButtonPressed = { [weak self] in
            self?.fetchUsersFromFirestore()
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
    
    private func fetchUsersFromFirestore() {
        loadingHud.show(in: view)
        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        query.getDocuments { [weak self] (snapshot, error) in
            self?.loadingHud.dismiss()
            if let error = error {
                print("Failed to fetch users:", error)
                return
            }
            snapshot?.documents.forEach {
                let user = User(dictionary: $0.data())
                self?.cardViewModels.append(user.toCardViewModel())
                self?.lastFetchedUser = user
                self?.setupCard(from: user)
            }
//            self?.setupFirestoreUserCards()
        }
    }
    
    private func setupCard(from user: User) {
        let cardView = CardView()
        cardView.cardViewModel = user.toCardViewModel()
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

