//
//  HomeViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
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
    private var topCardView: CardView?
    private var swipes = [String:Int]()
    private var users = [String: User]()
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        setupTopStackViewActions()
        setupBottomControlsActions()
        fetchCurrentUser()
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
        navigationController?.navigationBar.isHidden = true
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
        topStackView.messageButtonPressed = { [weak self] in
            guard let user = self?.user else { return }
            let matchesMessagesViewController = MatchesMessagesCollectionViewController(currentUser: user)
            self?.navigationController?.pushViewController(matchesMessagesViewController, animated: true)
        }
    }
    
    private func setupBottomControlsActions() {
        bottomControls.refreshButtonPressed = { [weak self] in
            self?.cardsDeckView.subviews.forEach { $0.removeFromSuperview() }
            self?.fetchCurrentUser()
        }
        bottomControls.dislikeButtonPressed = { [weak self] in
            self?.saveSwipeToFirestore(didLike: 0)
            self?.performSwipeAnimation(translation: -700, angle: -15)
        }
        bottomControls.likeButtonPressed = { [weak self] in
            self?.saveSwipeToFirestore(didLike: 1)
            self?.performSwipeAnimation(translation: 700, angle: 15)
        }
    }
    
    private func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    private func fetchCurrentUser() {
        loadingHud.show(in: view)
        cardsDeckView.subviews.forEach { $0.removeFromSuperview() }
        Firestore.firestore().fetchCurrentUser { [weak self] (user, error) in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            self?.user = user
            self?.fetchSwipes()
        }
    }
    
    private func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                print("Faield to fetch swipes for currently logged in user:", error)
                return
            }
            guard let swipes = snapshot?.data() as? [String:Int] else {
                self?.fetchUsersFromFirestore()
                return
            }
            self?.swipes = swipes
            self?.fetchUsersFromFirestore()
        }
    }
    
    private func fetchUsersFromFirestore() {
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: user?.minSeekingAge ?? SettingsTableViewController.defaultMinSeekingAge).whereField("age", isLessThanOrEqualTo: user?.maxSeekingAge ?? SettingsTableViewController.defaultMaxSeekingAge).limit(to: 10)
        topCardView = nil
        query.getDocuments { [weak self] (snapshot, error) in
            self?.loadingHud.dismiss()
            if let error = error {
                print("Failed to fetch users:", error)
                return
            }
            
            var previousCardView: CardView?
            
            snapshot?.documents.forEach {
                let user = User(dictionary: $0.data())
                self?.users[user.uid ?? ""] = user
                
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
//                let hasNotSwipedBefore = self?.swipes[user.uid ?? ""] == nil
                let hasNotSwipedBefore = true
                if isNotCurrentUser && hasNotSwipedBefore {
                    let cardView = self?.setupCard(from: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self?.topCardView == nil {
                        self?.topCardView = cardView
                    }
                }
            }
        }
    }
    
    private func setupCard(from user: User) -> CardView {
        let cardView = CardView()
        cardView.cardViewModel = user.toCardViewModel()
        cardView.delegate = self
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    private func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        let docData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                print("Failed to fetch swipe document:", error)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(docData) { (error) in
                    if let error = error {
                        print("Failed to save swipe data:", error)
                        return
                    }
                    print("Successfully updated swipe data...")
                    if didLike == 1 {
                        self?.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(docData) { (error) in
                    if let error = error {
                        print("Failed to save swipe data:", error)
                        return
                    }
                    print("Successfully saved swipe data...")
                    if didLike == 1 {
                        self?.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
    }
    
    private func checkIfMatchExists(cardUID: String) {
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                print("Failed to fetch document for card user:", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            print(data)
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("Has Matched")
                self?.presentMatchView(cardUID: cardUID)
                
                guard let cardUser = self?.users[cardUID] else { return }
                
                let data: [String:Any] = ["name": cardUser.name ?? "", "profileImageUrl": cardUser.imageUrl1 ?? "", "uid": cardUID, "timestamp": Timestamp(date: Date())]
                Firestore.firestore().collection("matches_messages").document(uid).collection("matches").document(cardUID).setData(data) { (error) in
                    if let error = error {
                        print("Failed to save match info:", error)
                        return
                    }
                }
                
                guard let currentUser = self?.user else { return }

                let otherMatchData: [String:Any] = ["name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "uid": currentUser.uid ?? "", "timestamp": Timestamp(date: Date())]
                Firestore.firestore().collection("matches_messages").document(cardUID).collection("matches").document(uid).setData(otherMatchData) { (error) in
                    if let error = error {
                        print("Failed to save match info:", error)
                        return
                    }
                }
            }
        }
    }
    
    private func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.currentUser = user
        matchView.cardUID = cardUID
        view.addSubview(matchView)
        matchView.fillSuperview()
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
    
    func cardViewDidRemoveCardView(_ cardView: CardView) {
        topCardView?.removeFromSuperview()
        topCardView = topCardView?.nextCardView
    }
    
    func cardViewDidLikeSwipe() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    func cardViewDidDislikeSwipe() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
}
