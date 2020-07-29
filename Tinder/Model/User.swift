//
//  User.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation
import UIKit

struct User: ProducesCardViewModel {
    
    let name : String
    let age : Int
    let profession : String
    let imageNames: [String]
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attributedString.append(NSAttributedString(string: "  \(age)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attributedString.append(NSAttributedString(string: "\n\(profession)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]))
        return CardViewModel(imageNames: imageNames, attributedString: attributedString, textAlignment: .left)
    }
}
