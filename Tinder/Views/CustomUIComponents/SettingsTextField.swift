//
//  SettingsTextField.swift
//  Tinder
//
//  Created by Peter Bassem on 7/30/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class SettingsTextField: UITextField {
    
    var nextButtonClicked: (() -> Void)?
    var doneButtonClicked: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        delegate = self
        autocapitalizationType = .words
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 44)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
}

extension SettingsTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if returnKeyType == .next {
            nextButtonClicked?()
        } else if returnKeyType == .done {
            doneButtonClicked?()
        }
        return true
    }
}
