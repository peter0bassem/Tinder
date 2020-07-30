//
//  RegistrationViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import JGProgressHUD

class RegistrationViewController: UIViewController {
    
    //MARK: - UI Components
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [#colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1).cgColor, #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1).cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = self.view.bounds
        return gradientLayer
    }()
    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Phtoto", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.widthAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(onSelectPhotoButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var fullNameTextField: CustomTextField = {
        let textField = CustomTextField(padding: 16)
        textField.placeholder = "Enter full name"
        textField.backgroundColor = .white
        textField.autocapitalizationType = .words
        textField.returnKeyType = .next
        textField.nextButtonClicked = { [weak self] in
            self?.emailTextField.becomeFirstResponder()
        }
        textField.addTarget(self, action: #selector(handleTextChange(_:)), for: .editingChanged)
        return textField
    }()
    private lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField(padding: 16)
        textField.placeholder = "Enter email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.backgroundColor = .white
        textField.returnKeyType = .next
        textField.nextButtonClicked = { [weak self] in
            self?.passwordTextField.becomeFirstResponder()
        }
        textField.addTarget(self, action: #selector(handleTextChange(_:)), for: .editingChanged)
        return textField
    }()
    private lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField(padding: 16)
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.doneButtonClicked = { [weak self] in
            self?.keyboardReturnButtonPressed = true
            self?.handleKeyboardHide()
        }
        textField.addTarget(self, action: #selector(handleTextChange(_:)), for: .editingChanged)
        return textField
    }()
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        //        button.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1)
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(onRegisterButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            fullNameTextField,
            emailTextField,
            passwordTextField,
            registerButton
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    private lazy var overallStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            selectPhotoButton,
            verticalStackView
        ])
        if self.traitCollection.verticalSizeClass == .compact {
            stackView.axis = .horizontal
        } else {
            stackView.axis = .vertical
        }
        stackView.spacing = 8
        return stackView
    }()
    private lazy var registeringHUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Register"
        return hud
    }()
    
    // MARK: - Variables
    private var keyboardReturnButtonPressed = false
    private lazy var registrationViewModel: RegistrationViewModel = {
        let registrationViewModel = RegistrationViewModel()
        return registrationViewModel
    }()
    
    // MARK: - UIViewController Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNotificationObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.layer.addSublayer(gradientLayer)
        setupLayout()
//        setupNotificationObservers()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewTapDismissKeyboard(_:))))
        setupRegistrationViewModelObserver()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        gradientLayer.frame = view.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact {
            overallStackView.axis = .horizontal
        } else {
            overallStackView.axis = .vertical
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        view.addSubview(overallStackView)
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupRegistrationViewModelObserver() {
        registrationViewModel.bindableIsFormValid.bind { [weak self] (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self?.registerButton.isEnabled = isFormValid
            self?.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1) : .lightGray
            self?.registerButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        }
        registrationViewModel.bindableImage.bind { [weak self] (image) in
            self?.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        registrationViewModel.bindableIsRegistering.bind { [weak self] (isRegistering) in
            if isRegistering == true {
                self?.registeringHUD.show(in: self?.view ?? UIView())
            } else {
                self?.registeringHUD.dismiss()
            }
        }
    }
    
    private func showHUDWithError(with error: Error) {
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.textLabel.text = "Failed Registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: view)
        hud.dismiss(afterDelay: 4)
    }
    
    // MARK: - Actions
    @objc private func handleTextChange(_ sender: UITextField) {
        if sender == fullNameTextField {
            registrationViewModel.fullName = sender.text
        } else if sender == emailTextField {
            registrationViewModel.email = sender.text
        } else if sender == passwordTextField {
            registrationViewModel.password = sender.text
        }
    }
    
    @objc private func handleKeyboardShow(_ sender: Notification) {
        guard let value = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        let bottomSpace = view.frame.size.height - overallStackView.frame.origin.y - overallStackView.frame.size.height
        
        let difference = keyboardFrame.height - bottomSpace
        view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    @objc private func handleKeyboardHide(_ sender: Notification? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            if self.keyboardReturnButtonPressed {
                self.view.endEditing(true)
                self.keyboardReturnButtonPressed = false
            }
            self.view.transform = .identity
        })
    }
    
    @objc private func handleViewTapDismissKeyboard(_ sender: UITapGestureRecognizer? = nil) {
        view.endEditing(true)
        
    }
    
    @objc private func onSelectPhotoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc private func onRegisterButtonPressed(_ sender: UIButton) {
        handleViewTapDismissKeyboard()
        registrationViewModel.performRegistration { [weak self] (error) in
            if let error = error {
                self?.showHUDWithError(with: error)
                return
            }
            print("Finish registering our user")
        }
    }
}

// MARK: - UIImagePickerControllerDelegate + UINavigationControllerDelegate
extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            registrationViewModel.bindableImage.value = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
