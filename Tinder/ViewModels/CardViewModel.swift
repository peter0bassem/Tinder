//
//  CardViewModel.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation
import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    private var imageIndex = 0 {
        didSet {
            imageIndexObserver?(imageIndex, UIImage(named: imageNames[imageIndex]))
        }
    }
    var imageIndexObserver: ((Int, UIImage?) -> Void)?
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
