//
//  CustomInputAccessoryView.swift
//  Tinder
//
//  Created by Peter Bassem on 8/2/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import LBTATools

class CustomInputAccessoryView: UIView {
    
    // MARK: - UI Components
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        NotificationCenter.default.addObserver(self, selector: #selector(onTextViewTextChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
        return textView
    }()
    private lazy var placeholderLabel: UILabel = {
        return UILabel(text: "Enter Message", font: .systemFont(ofSize: 16), textColor: .lightGray)
    }()
    private lazy var sendButton: UIButton = {
        let button = UIButton(title: "SEND", titleColor: .black, font: .boldSystemFont(ofSize: 14), target: self, action: #selector(onSendButtonPressed(_:)))
        button.constrainHeight(60)
        button.constrainWidth(60)
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Variables
    var sendButtonPressed: ((String) -> Void)?
    var clearsTextInputView: Bool! {
        didSet {
            textView.text = nil
            placeholderLabel.isHidden = !clearsTextInputView
            sendButton.isEnabled = !clearsTextInputView
        }
    }
    
    // MARK: - UIView Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        backgroundColor = .white
        setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)
        autoresizingMask = .flexibleHeight
        
        hstack(textView, sendButton, alignment: .center).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: sendButton.leadingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 0))
        placeholderLabel.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
    }
    
    // MARK: - Actions
    @objc private func onTextViewTextChange(_ sender: Notification) {
        placeholderLabel.isHidden = textView.text.count != 0
        sendButton.isEnabled = textView.text.count != 0
    }
    
    @objc private func onSendButtonPressed(_ sender: UIButton) {
        sendButtonPressed?(textView.text)
    }
}
