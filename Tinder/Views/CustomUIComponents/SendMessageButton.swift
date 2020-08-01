//
//  SendMessageButton.swift
//  Tinder
//
//  Created by Peter Bassem on 8/1/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class SendMessageButton: UIButton {
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [#colorLiteral(red: 1, green: 0.01176470588, blue: 0.4470588235, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.3921568627, blue: 0.3176470588, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        layer.cornerRadius = rect.size.height / 2
        clipsToBounds = true
        
        gradientLayer.frame = rect
    }
}
