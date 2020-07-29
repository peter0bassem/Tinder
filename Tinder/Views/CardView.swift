//
//  CardView.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
        return imageView
    }()

    private let threshold: CGFloat = 80
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.fillSuperview()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            handleChanged(sender)
        case .ended:
            handleEnded(sender)
        default: ()
        }
    }
    
    private func handleChanged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        // rotation
        // convert radian angle to degrees
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    private func handleEnded(_ sender: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = sender.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(sender.translation(in: nil).x) > threshold
        
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldDismissCard {
                
                // How to transform card off screen?
                //1
//                let offScreenTransform = self.transform.translatedBy(x: 1000, y: 0)
//                self.transform = offScreenTransform
                
                //2
//                self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height) // don't work on iOS 13!!
                self.center = CGPoint(x: 1000 * translationDirection, y: 0)
                
            } else {
                self.transform = .identity
            }
        }) { (_) in
            self.transform = .identity
            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.size.width, height: self.superview!.frame.size.height)
        }
    }
}
