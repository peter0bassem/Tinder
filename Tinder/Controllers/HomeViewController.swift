//
//  HomeViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    private lazy var topStackView: HomeTopNavigationStackView = {
        let stackView = HomeTopNavigationStackView()
        return stackView
    }()
    private lazy var cardsDeckView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var buttonsStackView: HomeBottomControlsStackView = {
        let stackView = HomeBottomControlsStackView()
        return stackView
    }()
    
//    var users = [
//        User(name: "Kelly", age: 23, profession: "Music DJ", imageName: "lady5c"),
//        User(name: "Jane", age: 18, profession: "Teacher", imageName: "lady4c")
//    ]
    
    let cardViewModels: [CardViewModel] = {
        let producers = [
        User(name: "Kelly", age: 23, profession: "Music DJ", imageNames: ["kelly1", "kelly2", "kelly3"]),
        User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"]),
        Advertiser(title: "Slide Out Menu", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster"),
        User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"])
        ] as [ProducesCardViewModel]
        return producers.map { return $0.toCardViewModel() }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        
        setupDummyCards()
    }
    
    private func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    private func setupDummyCards() {
        cardViewModels.forEach { (cardViewModel) in
            let cardView = CardView()
            cardView.cardViewModel = cardViewModel
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
}

