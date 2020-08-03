//
//  RecentMessage.swift
//  Tinder
//
//  Created by Peter Bassem on 8/3/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct RecentMessage {
    let text : String
    let uid : String
    let name : String
    let profileImageUrl : String
    let timestamp : Timestamp
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}
