//
//  CustomTextField.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    private let padding: CGFloat
    private let height: CGFloat
    
    var nextButtonClicked: (() -> Void)?
    var doneButtonClicked: (() -> Void)?
    
    init(padding: CGFloat, height: CGFloat) {
        self.padding = padding
        self.height = height
        super.init(frame: .zero)
        layer.cornerRadius = height / 2
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
}

extension CustomTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if returnKeyType == .next {
            nextButtonClicked?()
        } else if returnKeyType == .done {
            doneButtonClicked?()
        }
        return true
    }
}
