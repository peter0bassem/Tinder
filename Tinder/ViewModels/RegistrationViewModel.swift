//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Peter Bassem on 7/29/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegistrationViewModel {
    
    var fullName: String? { didSet { checkFormValidity() } }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()
    
    private func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && password?.count ?? 0 >= 6
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegistration(completion: @escaping (Error?) -> Void) {
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                completion(error)
                return
            }
            print("Successfully register user:", result?.user.uid ?? "")
            self?.saveImageToFirebaseStorage(completion: completion)
        }
    }
    
    private func saveImageToFirebaseStorage(completion: @escaping (Error?) -> Void) {
        let filename = UUID.init().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        ref.putData(imageData, metadata: metaData) { [weak self] (_, error) in
            if let error = error {
                completion(error)
                return
            }
            print("Finished uploading image to storage")
            ref.downloadURL { (url, error) in
                if let error = error {
                    completion(error)
                    return
                }
                self?.bindableIsRegistering.value = false
                print("download url of image:", url?.absoluteString ?? "")
                self?.saveInfoToFirestore(imageUrl: url?.absoluteString ?? "", completion: completion)
            }
        }
    }
    
    private func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData = ["fullName": fullName ?? "", "imageUrl1": imageUrl, "uid": uid]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
