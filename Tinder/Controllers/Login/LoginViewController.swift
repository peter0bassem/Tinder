//
//  LoginViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/31/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol LoginViewControllerDelegate: class {
    func didFinishLoggingIn()
}

class LoginViewController: UIViewController {
    
    //MARK: - UI Components
    private lazy var loggingHUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Logging in"
        return hud
    }()
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [#colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1).cgColor, #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1).cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = self.view.bounds
        return gradientLayer
    }()
    private lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField(padding: 24, height: 50)
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
        let textField = CustomTextField(padding: 24, height: 50)
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
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(onLoginButtonPressed), for: .touchUpInside)
        return button
    }()
    private lazy var overallStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    private lazy var backToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(onBackToRegisterButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Variables
    private var keyboardReturnButtonPressed = false
    private lazy var loginViewModel: LoginViewModel = {
        let loginViewModel = LoginViewModel()
        return loginViewModel
    }()
    weak var delegate: LoginViewControllerDelegate?
    
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
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewTapDismissKeyboard(_:))))
        setupLoginViewModelObserver()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(overallStackView)
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(backToRegisterButton)
        backToRegisterButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupLoginViewModelObserver() {
        loginViewModel.isFormValid.bind { [weak self] (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self?.loginButton.isEnabled = isFormValid
            self?.loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1) : .lightGray
            self?.loginButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        }
        loginViewModel.isLoggingIn.bind { [weak self] (isLoggingIn) in
            if isLoggingIn == true {
                DispatchQueue.main.async {
                    self?.loggingHUD.show(in: self?.view ?? UIView())
                }
            } else {
                DispatchQueue.main.async {
                    self?.loggingHUD.dismiss()
                }
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
        if sender == emailTextField {
            loginViewModel.email = sender.text
        } else if sender == passwordTextField {
            loginViewModel.password = sender.text
        }
    }
    
    @objc private func handleKeyboardShow(_ sender: Notification) {
        guard let value = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        let bottomSpace = view.frame.size.height - overallStackView.frame.origin.y - overallStackView.frame.size.height
        
        let difference = keyboardFrame.height - bottomSpace
        view.transform = CGAffineTransform(translationX: 0, y: difference)
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
    
    @objc private func onLoginButtonPressed(_ sender: UIButton) {
        handleViewTapDismissKeyboard()
        loginViewModel.performLogin { [weak self] (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showHUDWithError(with: error)
                }
                return
            }
            print("Logged in successfully")
            self?.dismiss(animated: true) {
                self?.delegate?.didFinishLoggingIn()
            }
        }
    }
    
    @objc private func onBackToRegisterButtonPressed(_ sender: UIButton) {
        let registerViewController = RegistrationViewController()
        registerViewController.delegate = delegate
        navigationController?.pushViewController(registerViewController, animated: true)
    }
}
