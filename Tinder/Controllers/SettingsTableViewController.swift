//
//  SettingsTableViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/30/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsTableViewControllerDelegate: class {
    func didSaveSettings()
}

class SettingsTableViewController: UITableViewController {
    
    // MARK: - UI Components
    private lazy var savingUserInformationHUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Settings"
        return hud
    }()
    private lazy var uploadImageHUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        return hud
    }()
    private lazy var headerView: UIView = {
       let view = UIView()
        let padding: CGFloat = 16
        
        view.addSubview(image1Button)
        image1Button.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, leading: image1Button.trailingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return view
    }()
    private lazy var image1Button: UIButton = {
        return self.createButton(selector: #selector(handleSelectPhoto))
    }()
    private lazy var image2Button: UIButton = {
        return self.createButton(selector: #selector(handleSelectPhoto))
    }()
    private lazy var image3Button: UIButton = {
        return self.createButton(selector: #selector(handleSelectPhoto))
    }()
    
    // MARK: - Variables
    var user: User?
    weak var delegate: SettingsTableViewControllerDelegate?
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupNavigationItems()
        tableView.backgroundColor = .init(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
    }
    
    // MARK: - Helpers
    private func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancelBarButtonPressed(_:)))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onSaveBarButtonPressed(_:))),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(onLogoutBarButtonPressed(_:)))
        ]
    }
    
    private func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    private func fetchCurrentUser() {
        Firestore.firestore().fetchCurrentUser { [weak self] (user, error) in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            self?.user = user
            self?.loadUserPhotos()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func loadUserPhotos() {
        SDWebImageManager.shared.loadImage(with: URL(string: user?.imageUrl1 ?? ""), options: .continueInBackground, progress: nil) { [weak self] (image, _, _, _, _, _) in
            DispatchQueue.main.async {
                self?.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        SDWebImageManager.shared.loadImage(with: URL(string: user?.imageUrl2 ?? ""), options: .continueInBackground, progress: nil) { [weak self] (image, _, _, _, _, _) in
            DispatchQueue.main.async {
                self?.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        SDWebImageManager.shared.loadImage(with: URL(string: user?.imageUrl3 ?? ""), options: .continueInBackground, progress: nil) { [weak self] (image, _, _, _, _, _) in
            DispatchQueue.main.async {
                self?.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func onCancelBarButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func onSaveBarButtonPressed(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData: [String:Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ]
        savingUserInformationHUD.show(in: view)
        Firestore.firestore().collection("users").document(uid).setData(docData) { [weak self] (error) in
            DispatchQueue.main.async {
                self?.savingUserInformationHUD.dismiss()
            }
            if let error = error {
                print("Failed to save user settings:", error)
                return
            }
            print("Successfully Saved user info")
            self?.dismiss(animated: true) {
                print("Dismissal complete")
                self?.delegate?.didSaveSettings()
            }
        }
    }
    
    @objc private func onLogoutBarButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch let error {
            print("Failed to sign out:", error)
        }
    }
    
    @objc private func handleSelectPhoto(_ sender: UIButton) {
        let imagePickerController = CustomImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        imagePickerController.imageButton = sender
        present(imagePickerController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 5 {
            let cell = AgeRangeTableViewCell(style: .default, reuseIdentifier: nil)
            cell.minSeekingRangeValue = user?.minSeekingAge
            cell.maxSeekingRangeValue = user?.maxSeekingAge
            cell.minSliderValueChange = { [weak self] (value) in
                self?.user?.minSeekingAge = value
            }
            cell.maxSliderValueChange = { [weak self] (value) in
                self?.user?.maxSeekingAge = value
            }
            return cell
        }
        let cell = SettingsTableViewCell(style: .default, reuseIdentifier: nil)
        switch indexPath.section {
        case 1:
            cell.placeholderText = "Enter Name"
            cell.userInformationText = user?.name
            cell.keyboardReturnType = .next
//            cell.keyboardType = .default
            cell.keyboardNextAction = {
                guard let nextCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SettingsTableViewCell else { return }
                nextCell.makeTextFieldFirstResponder()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .none, animated: true)
            }
            cell.nameTextFieldTextChange = { [weak self] (name) in
                self?.user?.name = name
            }
        case 2:
            cell.placeholderText = "Enter Profession"
            cell.userInformationText = user?.profession
            cell.keyboardReturnType = .next
//            cell.keyboardType = .default
            cell.keyboardNextAction = {
                guard let nextCell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? SettingsTableViewCell else { return }
                nextCell.makeTextFieldFirstResponder()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .none, animated: true)
            }
            cell.professionTextFieldTextChange = { [weak self] (profession) in
                self?.user?.profession = profession
            }
        case 3:
            cell.placeholderText = "Enter Age"
            if let age = user?.age {
                cell.userInformationText = String(age)
            }
            cell.keyboardReturnType = .next
//            cell.keyboardType = .numberPad
            
            cell.keyboardNextAction = {
                guard let nextCell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as? SettingsTableViewCell else { return }
                nextCell.makeTextFieldFirstResponder()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .none, animated: true)
            }
            cell.ageTextFieldTextChange = { [weak self] (age) in
                self?.user?.age = Int(age ?? "")
            }
        case 4:
            cell.placeholderText = "Enter Bio"
            cell.keyboardReturnType = .done
//            cell.keyboardType = .default
            cell.keyboardDoneAction = {
                cell.makeTextFieldResignFirstResponder()
            }
            cell.bioTextFieldTextChange = { (bio) in
            }
        default: ()
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsTableViewController {
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headerView
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1: headerLabel.text = "Name"
        case 2: headerLabel.text = "Profession"
        case 3: headerLabel.text = "Age"
        case 4: headerLabel.text = "Bio"
        case 5: headerLabel.text = "Seeking Age Range"
        default: ()
        }
        headerLabel.font = .boldSystemFont(ofSize: 16)
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
}

// MARK: - UIImagePickerControllerDelegate + UINavigationControllerDelegate
extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            let imageButton = (picker as? CustomImagePickerController)?.imageButton
            imageButton?.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            
            // upload image into storage
            let filename = UUID.init().uuidString
            let ref = Storage.storage().reference(withPath: "/images/\(filename)")
            guard let uploadData = image.jpegData(compressionQuality: 0.75) else { return }
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            uploadImageHUD.show(in: view)
            ref.putData(uploadData, metadata: metaData) { [weak self] (_, error) in
                if let error = error {
                    print("Failed to upload image:", error)
                    return
                }
                print("Finished uploading image")
                ref.downloadURL { (url, error) in
                    self?.uploadImageHUD.dismiss()
                    if let error = error {
                        print(error)
                        return
                    }
                    print("image url:", url?.absoluteString ?? "")
                    
                    if imageButton == self?.image1Button {
                        self?.user?.imageUrl1 = url?.absoluteString
                    } else if imageButton == self?.image2Button {
                        self?.user?.imageUrl2 = url?.absoluteString
                    } else if imageButton == self?.image3Button {
                        self?.user?.imageUrl3 = url?.absoluteString
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
