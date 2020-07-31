//
//  LoginViewModel.swift
//  Tinder
//
//  Created by Peter Bassem on 7/31/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation
import Firebase

class LoginViewModel {
    
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    var isLoggingIn = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    
    private func checkFormValidity() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFormValid.value = isValid
    }
    
    func performLogin(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        isLoggingIn.value = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            self?.isLoggingIn.value = false
            completion(error)
        }
    }
}
