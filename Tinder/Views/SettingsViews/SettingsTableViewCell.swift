//
//  SettingsTableViewCell.swift
//  Tinder
//
//  Created by Peter Bassem on 7/30/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    static let identifier = "SettingsTableViewCell"
    
    // MARK: - UI Components
    private lazy var textField: SettingsTextField = {
        let textField = SettingsTextField()
        textField.placeholder = "Enter name"
        textField.addTarget(self, action: #selector(handleTextChange(_:)), for: .editingChanged)
        return textField
    }()
    
    // MARK: - Variables
    var keyboardNextAction: (() -> Void)?
    var keyboardDoneAction: (() -> Void)?
    
    var nameTextFieldTextChange: ((String?) -> Void)?
    var professionTextFieldTextChange: ((String?) -> Void)?
    var ageTextFieldTextChange: ((String?) -> Void)?
    var bioTextFieldTextChange: ((String?) -> Void)?
    
    var placeholderText: String! {
        didSet {
            textField.placeholder = placeholderText
        }
    }
    var userInformationText: String? {
        didSet {
            textField.text = userInformationText
        }
    }
    var keyboardReturnType: UIReturnKeyType! {
        didSet {
            textField.returnKeyType = keyboardReturnType
        }
    }
    var keyboardType: UIKeyboardType! {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    // MARK: - UITableViewCell Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
        textField.fillSuperview()
        
        textField.nextButtonClicked = {
            self.keyboardNextAction?()
        }
        textField.doneButtonClicked = {
            self.keyboardDoneAction?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func makeTextFieldFirstResponder() {
        textField.becomeFirstResponder()
    }
    
    func makeTextFieldResignFirstResponder() {
        textField.resignFirstResponder()
    }
    
    // MARK: - Actions
    @objc private func handleTextChange(_ sender: UITextField) {
        nameTextFieldTextChange?(sender.text)
        professionTextFieldTextChange?(sender.text)
        ageTextFieldTextChange?(sender.text)
        bioTextFieldTextChange?(sender.text)
    }
}
