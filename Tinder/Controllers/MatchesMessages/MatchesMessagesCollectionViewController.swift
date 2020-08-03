//
//  MatchesMessagesCollectionViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 8/1/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools
import FirebaseFirestore
import FirebaseAuth

class MatchesMessagesCollectionViewController: LBTAListHeaderController<RecentMessageCollectionViewCell, RecentMessage, MatchesHeaderCollectionReusableView> {
    
    // MARK: - UI Components
    private lazy var customNavigationBar: MatchesNavigationBar = {
        let customNavigationBar = MatchesNavigationBar()
        return customNavigationBar
    }()
    private lazy var statusBarCover: UIView = {
        let view = UIView(backgroundColor: .white)
        return view
    }()
    
    // MARK: - Variables
    private var currentUser: User
    var currentLoggedInUser: User { return currentUser }
    private var recentMessagesDictionary = [String: RecentMessage]()
    private var listener: ListenerRegistration?
    
    // MARK: - UICollectionViewController Lifecycle
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.backgroundColor = .white
        collectionView.contentInset.top = 170
        collectionView.showsVerticalScrollIndicator = false
        setupLayout()
        setupNavigationBarActions()
        fetchRecentMessages()
    }
    
    override func setupHeader(_ header: MatchesHeaderCollectionReusableView) {
        header.rootMessagesViewController = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    deinit {
        print("Deinit MatchesMessagesCollectionViewController")
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        view.addSubview(customNavigationBar)
        customNavigationBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupNavigationBarActions() {
        customNavigationBar.backButtonPressed = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func fetchRecentMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = Firestore.firestore().collection("matches_messages").document(uid).collection("recent_messages")
            listener = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Failed to fetch recent messages:", error)
                return
            }
            querySnapshot?.documentChanges.forEach {
                if $0.type == .added || $0.type == .modified {
                    let recentMessage = RecentMessage(dictionary: $0.document.data())
                    self?.recentMessagesDictionary[recentMessage.uid] = recentMessage
                    self?.items.append(recentMessage)
                }
            }
            self?.resetItems()
        }
    }
    
    private func resetItems() {
        let values = Array(recentMessagesDictionary.values)
        items = values.sorted { return $0.timestamp.compare($1.timestamp) == .orderedDescending
        }
        collectionView.reloadData()
    }
    
    // MARK: - Actions
}

// MARK: - UICollectionViewDataSource
extension MatchesMessagesCollectionViewController {
    
}

// MARK: - UICollectionViewDataDelegate
extension MatchesMessagesCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentMessage = items[indexPath.item]
        let dictionary = ["name": recentMessage.name, "profileImageUrl": recentMessage.profileImageUrl, "uid": recentMessage.uid]
        let match = Match(dictionary: dictionary)
        let chatLogCollectionViewController = ChatLogCollectionViewController(currentUser: currentUser, match: match)
        navigationController?.pushViewController(chatLogCollectionViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MatchesMessagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.size.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.size.width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 16, right: 0)
    }
}
