//
//  MatchesHorizontalCollectionViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 8/3/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools
import FirebaseAuth
import FirebaseFirestore

class MatchesHorizontalCollectionViewController: LBTAListController<MatchCollectionViewCell, Match> {
    
    // MARK: - UI Components
    
    // MARK: - Variables
    weak var rootMessagesViewController: MatchesMessagesCollectionViewController?
    
    // MARK: - UICollectionView Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.showsHorizontalScrollIndicator = false
        fetchMatches()
    }
    
    // MARK: - Helpers
    private func fetchMatches() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("matches").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Failed to fetch matcehs:", error)
                return
            }
            print("Here is my matches documents")
            var matches = [Match]()
            querySnapshot?.documents.forEach { matches.append(.init(dictionary: $0.data())) }
            self?.items = matches
            self?.collectionView.reloadData()
        }
    }
    
    // MARK: - Actions
}

// MAR: - UICollectionViewDelegate
extension MatchesHorizontalCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUser = rootMessagesViewController?.currentLoggedInUser else { return }
        let chatLogCollectionViewController = ChatLogCollectionViewController(currentUser: currentUser, match: items[indexPath.item])
        rootMessagesViewController?.navigationController?.pushViewController(chatLogCollectionViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MatchesHorizontalCollectionViewController: UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 4, bottom: 0, right: 16)
    }
}
