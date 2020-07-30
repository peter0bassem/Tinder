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
    
    var uid : String?
    var name : String?
    var age : Int?
    var profession : String?
//    let imageNames: [String]
    var imageUrl1 : String?
    
    init(dictionary: [String:Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.imageUrl1 = dictionary["imageUrl1"] as? String ?? ""
    }
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: name ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
        let ageString = age != nil ? "\(age!)" : "N\\A"
        attributedString.append(NSAttributedString(string: "  \(ageString)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .regular)]))
        let professionString = profession != nil ? profession! : "Not available"
        attributedString.append(NSAttributedString(string: "\n\(professionString)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]))
        return CardViewModel(imageNames: [imageUrl1 ?? ""], attributedString: attributedString, textAlignment: .left)
    }
}
