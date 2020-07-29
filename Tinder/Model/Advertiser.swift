//
//  Advertiser.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation
import UIKit

struct Advertiser: ProducesCardViewModel {
    let title : String
    let brandName : String
    let posterPhotoName : String
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedString.append(NSAttributedString(string: "\n\(brandName)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .bold)]))
        return CardViewModel(imageNames: [posterPhotoName], attributedString: attributedString, textAlignment: .center)
    }
}
