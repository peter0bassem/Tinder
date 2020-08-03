//
//  Match.swift
//  Tinder
//
//  Created by Peter Bassem on 8/2/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation

struct Match {
    let name : String
    let profileImageUrl : String
    let uid : String
    
    init(dictionary: [String:Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
