//
//  ChatLogCollectionViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 8/2/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools
import FirebaseFirestore
import FirebaseAuth

class ChatLogCollectionViewController: LBTAListController<MessageCollectionViewCell, Message> {
    
    // MARK: - UI Components
    private lazy var customNavigationBar: MessagesNavigationBar = {
        let customNavigationBar = MessagesNavigationBar(match: self.match)
        return customNavigationBar
    }()
    private lazy var statusBarCover: UIView = {
        let view = UIView(backgroundColor: .white)
        return view
    }()
    private lazy var customInputView: CustomInputAccessoryView = {
        return CustomInputAccessoryView(frame: .init(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
    }()
    
    // MARK: - Variables
    private let navigationBarHeight: CGFloat = 120
    private let match: Match
    private var currentUser: User?
    var listener: ListenerRegistration?
    
    //MARK: - UICollectionViewController Lifecycle
    init(currentUser: User, match: Match) {
        self.currentUser = currentUser
        self.match = match
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.backgroundColor = .white
        collectionView.contentInset.top = navigationBarHeight
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.showsVerticalScrollIndicator = false
        setupKeyboardNotifications()
        setupLayout()
        setupNavigationBarActions()
        setupAccessoryInputViewActions()
        fetchMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    deinit {
        print("Deinit ChatLogViewController")
    }
    
    // TODO: - Input accessory view
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return customInputView
        }
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        view.addSubview(customNavigationBar)
        customNavigationBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navigationBarHeight))
        
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private func fetchMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = Firestore.firestore().collection("matches_messages").document(uid).collection(match.uid).order(by: "timestamp")
        
        listener = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Failed to fetch messages:", error)
                return
            }
            querySnapshot?.documentChanges.forEach {
                if $0.type == .added {
                    self?.items.append(.init(dictionary: $0.document.data()))
                }
            }
            self?.collectionView.reloadData()
            self?.collectionView.scrollToItem(at: [0, self?.items.count ?? 0 - 1], at: .bottom, animated: true)
        }
    }
    
    private func setupNavigationBarActions() {
        customNavigationBar.backButtonPressed = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupAccessoryInputViewActions() {
        customInputView.sendButtonPressed = { [weak self] (messageText) in
            self?.saveToFromMessages(with: messageText)
            self?.saveToFromRecentMessages(with: messageText)
        }
    }
    
    private func saveToFromMessages(with messageText: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let collection = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid)
        
        let data: [String:Any] = [
            "text": messageText,
            "fromId": currentUserId,
            "toId": match.uid,
            "timestamp": Timestamp(date: Date())
        ]
        collection.addDocument(data: data) { [weak self] (error) in
            if let error = error {
                print("Failed to save message:", error)
                return
            }
            print("Successfully saved message into firestore")
            self?.customInputView.clearsTextInputView = true
        }
        
        let toCollection = Firestore.firestore().collection("matches_messages").document(match.uid).collection(currentUserId)
        
        toCollection.addDocument(data: data) { [weak self] (error) in
            if let error = error {
                print("Failed to save message:", error)
                return
            }
            print("Successfully saved message into firestore")
            self?.customInputView.clearsTextInputView = true
        }
    }
    
    private func saveToFromRecentMessages(with messageText: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let data: [String:Any] = ["text": messageText, "name": match.name, "profileImageUrl": match.profileImageUrl, "timestamp": Timestamp(date: Date()), "uid": match.uid]
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").document(match.uid).setData(data) { (error) in
            if let error = error {
                print("Failed to save recent message:", error)
                return
            }
            print("Saved recent message")
        }
        
        // save the other direction
        guard let currentUser = currentUser else { return }
        let toData: [String:Any] = ["text": messageText, "name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "timestamp": Timestamp(date: Date()), "uid": currentUserId]
        Firestore.firestore().collection("matches_messages").document(match.uid).collection("recent_messages").document(currentUserId).setData(toData) { (error) in
            if let error = error {
                print("Failed to save recent message:", error)
                return
            }
            print("Saved recent message")
        }
    }
    
    // MARK: - Actions
    @objc private func onKeyboardShow(_ sender: Notification) {
        collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChatLogCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let estimatedSizeCell = MessageCollectionViewCell(frame: .init(x: 0, y: 0, width: collectionView.frame.size.width, height: 1000))
        estimatedSizeCell.item = items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: collectionView.frame.size.width, height: 1000))
        
        return .init(width: view.frame.size.width, height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
}
