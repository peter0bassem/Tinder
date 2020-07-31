//
//  HeaderLabel.swift
//  Tinder
//
//  Created by Peter Bassem on 7/30/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class HeaderLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}
